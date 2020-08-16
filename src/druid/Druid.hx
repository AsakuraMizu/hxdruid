package druid;

import defold.support.ScriptOnInputAction;
import defold.types.*;
import druid.types.*;

/**
    Druid main class. Create instance of this to start creating components
**/
class Druid<T:{}> {
    /**
        Druid context. Usually it is self of script
    **/
    private var context:T;

    /**
        Druid style
    **/
    private var style:DruidStyle;

    public var deleted(default, null):Bool = false;
    public var url(default, null):Url;

    private var is_input_processing:Bool = false;
    private final late_remove:Array<Component<T>> = [];

    public final all_components:Array<Component<T>> = [];
    public final components:Map<Interest, Array<Component<T>>> = [];

    private var input_inited:Bool = false;

    /**
        Druid class constructor

        @param context Druid context. Usually it is self of script
        @param druid_style Druid style
    **/
    public function new(context:T, ?style:DruidStyle) {
        this.context = context;
        this.style = style;

        url = defold.Msg.url();

        for (i in Const.ALL_INTERESTS)
            components.set(i, []);
    }

    /**
        Set druid style

        Invoke `set_style` on every component.

        @param druid_style druid style
    **/
    public function set_style(?style: DruidStyle):Void {
        this.style = style;
        for (i in all_components)
            i.set_style(style);
    }

    /**
        Call on final function on gui_script. It will call on_remove
        on all druid components
    **/
    @:native("final")
    public function final_():Void {
        for (i in all_components)
            i.on_remove();

        deleted = true;
        input_release();
    }

    private function input_init():Void {
        if (defold.Sys.get_config("druid.no_auto_input") == "1")
            return;

        if (!input_inited) {
            input_inited = true;
            Helper.Input.focus();
        }
    }

    private function input_release():Void {
        if (defold.Sys.get_config("druid.no_auto_input") == "1")
            return;

        if (input_inited) {
            input_inited = false;
            Helper.Input.remove();
        }
    }

    /**
        Add component

        @param component Component
    **/
    public function add(component: Component<T>):Component<T> {
        component.init(this, this.context, this.style);

        all_components.push(component);

        var init_input = false;
        for (i in component.interest) {
            components[i].push(component);

            if (Const.UI_INPUT.contains(i))
                init_input = true;
        }

        if (init_input)
            input_init();

        return component;
    }

    /**
        Remove component from druid instance

        Component `on_remove` function will be invoked, if exist.

        @param component Component instance
    **/
    public function remove(component: Component<T>):Void {
        if (is_input_processing) {
            late_remove.push(component);
            return;
        }

        for (i in all_components)
            if (i.is_child_of(component))
                remove(i);

        for (i in all_components) {
            if (i == component) {
                i.on_remove();
                all_components.remove(component);
            }
        }

        for (i in component.interest) {
            for (j in components[i]) {
                if (j == component)
                    components[i].remove(component);
            }
        }
    }

    private function process_input(
            action_id:Hash, action:ScriptOnInputAction, components:Array<Component<T>>, is_input_consumed:Bool
        ):Bool {

        components = components.copy();
        // Process increased input priority first
        components.sort((a, b) -> a.increased_input_priority ?
            b.increased_input_priority ? 0 : -1
            :
            b.increased_input_priority ? 1 : 0
        );

        for (i in components) {
            if (!is_input_consumed)
                is_input_consumed = i.on_input(action_id, action);
            else
                i.on_input_interrupt();
        }

        return is_input_consumed;
    }

    /**
        Druid on_input function
    **/
    public function on_input(action_id:Hash, action:ScriptOnInputAction):Bool {
        is_input_processing = true;

        var is_input_consumed = false;

        is_input_consumed = process_input(action_id, action, components[Const.ON_INPUT_HIGH], is_input_consumed);
        is_input_consumed = process_input(action_id, action, components[Const.ON_INPUT], is_input_consumed);

        is_input_processing = false;

        while (late_remove.length > 0)
            remove(late_remove.pop());

        return is_input_consumed;
    }

    /**
        Druid on_message function
    **/
    public function on_message<TMessage>(message_id:Message<TMessage>, message:TMessage, sender:Url):Void {
        var specific_ui_message = Const.SPECIFIC_UI_MESSAGES[cast {msg:message_id}];

        if (specific_ui_message != null) {
            for (i in components[specific_ui_message.interest]) {
                var func = Reflect.field(i, specific_ui_message.name);
                if (Reflect.isFunction(func))
                    func();
            }
        } else {
            for (i in components[Const.ON_MESSAGE])
                i.on_message(message_id, message, sender);
        }
    }

    /**
        Druid update function

        @param dt Delta time
    **/
    public function update(dt:Float):Void
        for (i in components[Const.ON_UPDATE])
            i.update(dt);

    /**
        Druid on focus lost interest function

        This one called by on_window_callback by global window listener
    **/
    public function on_focus_lost():Void
        for (i in components[Const.ON_FOCUS_LOST])
            i.on_focus_lost();

    /**
        Druid on focus gained interest function

        This one called by on_window_callback by global window listener
    **/
    public function on_focus_gained():Void
        for (i in components[Const.ON_FOCUS_GAINED])
            i.on_focus_gained();

    /**
        Druid on layout change function

        Called on update gui layout
    **/
    public function on_layout_change():Void
        for (i in components[Const.ON_LAYOUT_CHANGE])
            i.on_layout_change();

    /**
        Druid on language change

        This one called by global gruid.on_language_change, but can be
        call manualy to update all translations
    **/
    public function on_language_change():Void
        for (i in components[Const.ON_LANGUAGE_CHANGE])
            i.on_language_change();
}