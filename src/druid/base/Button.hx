package druid.base;

import lua.lib.luasocket.Socket;
import defold.Gui;
import defold.support.ScriptOnInputAction;
import defold.types.Hash;
import defold.types.Vector3;
import druid.types.ComponentStyle;
import druid.types.DruidStyle;
import druid.types.NodeOrString;

/**
    Component to handle basic GUI button
**/
class Button<T:{}> extends Component<T> {
    private var node:GuiNode;
    private var click_zone:GuiNode;
    private var hover:Hover<T>;

    private var is_repeated_started:Bool = false;
    private var last_pressed_time:Float = 0;
    private var last_released_time:Float = 0;
    private var can_action:Bool = false;

    /**
        Button enabled state
    **/
    public var is_enabled(default, set):Bool = true;

    /**
        Animation node
    **/
    public var anim_node(default, null):GuiNode;

    /**
        Initial scale of anim_node
    **/
    public var start_scale(default, null):Vector3;

    /**
        Initial pos of anim_node
    **/
    public var start_pos(default, null):Vector3;

    /**
        Key-code to trigger this button
    **/
    public var key_trigger:Hash;

    public var click_in_row(default, null):Int = 0;

    /**
        On release button callback
    **/
    public var on_click(default, null):Event<T -> Void>;

    /**
        On repeated action button callback
    **/
    public var on_repeated_click(default, null):Event<(T, Int) -> Void>;

    /**
        On long tap button callback
    **/
    public var on_long_click(default, null):Event<(T, Float) -> Void>;

    /**
        On double tap button callback
    **/
    public var on_double_click(default, null):Event<(T, Int) -> Void>;

    /**
        On button hold before long_click
    **/
    public var on_hold_callback(default, null):Event<(T, Float) -> Void>;

    /**
        On click outside of button
    **/
    public var on_click_outside(default, null):Event<T -> Void>;

    /**
        Component constructor

        @param node Gui node
        @param callback Button callback
        @param params Button callback params
        @param anim_node Button anim node
    **/
    public function new(
            node:NodeOrString, ?callback:T -> Void, ?anim_node:NodeOrString
        ) {
        name = "Button";
        interest = [Const.ON_INPUT];

        this.node = get_node(node);
        if (anim_node == null) {
            this.anim_node = this.node;
        } else {
            this.anim_node = get_node(anim_node);
        }

        start_scale = Gui.get_scale(this.anim_node);
        start_pos = Gui.get_position(this.anim_node);

        hover = new Hover(node, on_button_hover);
        hover.on_mouse_hover.subscribe(on_button_mouse_hover);

        on_click = new Event(callback);
        on_repeated_click = new Event();
        on_long_click = new Event();
        on_double_click = new Event();
        on_hold_callback = new Event();
        on_click_outside = new Event();
    }

    override function init(druid:Druid<T>, context:T, ?druid_style:DruidStyle) {
        super.init(druid, context, druid_style);

        add_child(hover);
    }

    override function on_input(action_id:Hash, action:ScriptOnInputAction):Bool {
        if (!is_input_match(action_id))
            return false;

        if (!Helper.is_enabled(node))
            return false;

        var is_pick = true;
        var is_key_trigger = (action_id == key_trigger);
        if (!is_key_trigger) {
            is_pick = Gui.pick_node(node, action.x, action.y);
            if (click_zone != null)
                is_pick = is_pick && Gui.pick_node(click_zone, action.x, action.y);
        }

        if (!is_pick) {
            can_action = false;
            if (action.released)
                on_click_outside.trigger([context]);
            return false;
        }

        if (is_key_trigger) {
            hover.set_hover(!action.released);
        }

        if (action.pressed) {
            // Can interact if start touch on the button
            can_action = true;
            is_repeated_started = false;
            last_pressed_time = Socket.gettime();
            return true;
        }

        // While hold button, repeat rate pick from input.repeat_interval
        if (action.repeated) {
            if (is_enabled && can_action && on_repeated_click.is_exist()) {
                on_repeated_click.trigger([context]);
                return true;
            }
        }

        if (action.released)
            return on_button_release();

        if (is_enabled && can_action && on_long_click.is_exist()) {
            var press_time = Socket.gettime() - last_pressed_time;

            if ((style["AUTOHOLD_TRIGGER"]:Float) <= press_time) {
                on_button_release();
                return true;
            }

            if ((style["LONGTAP_TIME"]:Float) <= press_time) {
                on_button_hold(press_time);
                return true;
            }
        }

        return is_enabled;
    }

    override function on_input_interrupt() {
        can_action = false;
    }

    override function on_style_change(?style:ComponentStyle) {
        if (style == null)
            style = [];

        var set:(String, Dynamic) -> Void = Helper.null_default.bind(style, _, _);

        set("LONGTAP_TIME", .4);
        set("AUTOHOLD_TRIGGER", .8);
        set("DOUBLETAP_TIME", .4);
        set("on_click", (_, _) -> {});
        set("on_click_disabled", (_, _) -> {});
        set("on_mouse_hover", (_, _, _) -> {});
        set("on_hover", (_, _, _) -> {});
        set("on_set_enabled", (_, _, _) -> {});

        this.style = style;
    }

    /**
        Strict button click area. Useful for
        no click events outside stencil node

        @param zone Gui node
    **/
    public function set_click_zone(zone:NodeOrString):Void
        click_zone = get_node(zone);

    private function is_input_match(action_id:Hash):Bool {
        if (action_id == Const.ACTION_TOUCH)
            return true;

        return false;
    }

    private function on_button_hover(_:T, hover_state:Bool):Void
        invoke_style("on_hover", [anim_node, hover_state]);

    private function on_button_mouse_hover(_:T, hover_state:Bool):Void
        invoke_style("on_mouse_hover", [anim_node, hover_state]);

    private function on_button_click():Void {
        invoke_style("on_click", [anim_node]);

        click_in_row = 1;
        on_click.trigger([context]);
    }

    private function on_button_repeated_click():Void {
        if (!is_repeated_started) {
            click_in_row = 0;
            is_repeated_started = true;
        }

        invoke_style("on_click", [anim_node]);

        click_in_row += 1;
        on_repeated_click.trigger([context, click_in_row]);
    }

    private function on_button_long_click():Void {
        invoke_style("on_click", [anim_node]);

        click_in_row = 1;
        var time = Socket.gettime() - last_pressed_time;
        on_long_click.trigger([context, time]);
    }

    private function on_button_double_click():Void {
        invoke_style("on_click", [anim_node]);

        click_in_row += 1;
        on_double_click.trigger([context, click_in_row]);
    }

    private function on_button_hold(press_time:Float):Void {
        on_hold_callback.trigger([context, press_time]);
    }

    private function on_button_release():Bool {
        if (is_repeated_started)
            return false;

        if (is_enabled) {
            if (can_action) {
                var time = Socket.gettime();

                var is_long_click = style["LONGTAP_TIME"] < (time - last_pressed_time);
                is_long_click = is_long_click && on_long_click.is_exist();

                var is_double_click = style["DOUBLETAP_TIME"] < (time - last_released_time);
                is_double_click = is_double_click && on_double_click.is_exist();

                if (is_long_click)
                    on_button_long_click();
                else if (is_double_click)
                    on_button_double_click();
                else on_button_click();

                last_released_time = time;
            }
            return true;
        } else {
            invoke_style("on_click_disabled", [anim_node]);
            return false;
        }
    }

    public function set_is_enabled(state:Bool):Bool {
        hover.is_enabled = state;
        invoke_style("on_set_enabled", [node, state]);
        return state;
    }
}