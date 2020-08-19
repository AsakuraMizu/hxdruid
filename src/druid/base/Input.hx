package druid.base;

import lua.HaxeIterator;
import lua.NativeStringTools as LuaString;
import defold.Gui;
import defold.support.ScriptOnInputAction;
import defold.types.Hash;
import druid.types.ComponentStyle;
import druid.types.DruidStyle;
import druid.types.NodeOrString;

/**
    Druid input text component
    Carry on user text input
**/
@:access(druid.base.Button.node)
class Input<T:{}> extends Component<T> {
    private var keyboard_type:GuiKeyboardType;
    private var selected:Bool = false;
    private var is_empty:Bool = true;
    private var value:String;
    private var previous_value:String;
    private var current_value:String;
    private var marked_value:String = "";
    private var text_width:Float = 0;
    private var marked_text_width:Float = 0;
    private var total_width:Float = 0;

    private var text:Text<T>;
    private var button:Button<T>;

    /**
        Max length for input text
    **/
    public var max_length:Int;

    /**
        Pattern matching for user input
    **/
    public var allowed_characters:String;

    /**
        On input field select callback
    **/
    public var on_input_select(default, null):Event<T -> Void>;

    /**
        On input field unselect callback
    **/
    public var on_input_unselect:Event<T -> Void>;

    /**
        On input field text change callback
    **/
    public var on_input_text:Event<(T, String) -> Void>;

    /**
        On input field text change to empty string callback
    **/
    public var on_input_empty(default, null):Event<(T, String) -> Void>;

    /**
        On input field text change to max length string callback
    **/
    public var on_input_full(default, null):Event<(T, String) -> Void>;

    /**
        On trying user input with not allowed character callback
    **/
    public var on_input_wrong(default, null):Event<(T, String) -> Void>;

    /**
        Component constructor

        @param click_node
        @param text_node
        @param keyboard_type
    **/
    @:access(druid.base.Text.last_value)
    public function new(click_node:NodeOrString, text_node:NodeOrString, ?keyboard_type:GuiKeyboardType = KEYBOARD_TYPE_DEFAULT) {
        name = "Input";
        interest = [Const.ON_INPUT, Const.ON_FOCUS_LOST];

        this.keyboard_type = keyboard_type;

        text = new Text(text_node);
        current_value = previous_value = value = text.last_value;

        button = new Button(click_node, self -> select());
        button.on_click_outside.subscribe(self -> unselect());
        button.on_long_click.subscribe((self, time) -> clear_and_select());

        on_input_select = new Event();
        on_input_unselect = new Event();
        on_input_text = new Event();
        on_input_empty = new Event();
        on_input_full = new Event();
        on_input_wrong = new Event();
    }

    override function init(druid:Druid<T>, context:T, ?druid_style:DruidStyle) {
        super.init(druid, context, druid_style);

        add_child(text);
        add_child(button);
    }

    override function on_style_change(?style:ComponentStyle) {
        if (style == null)
            style = [];

        var set:(String, Dynamic) -> Void = Helper.null_default.bind(style, _, _);

        set("IS_LONGTAP_ERASE", false);
        set("MASK_DEFAULT_CHAR", "*");
        set("on_select", (_, _) -> {});
        set("on_unselect", (_, _) -> {});
        set("on_input_wrong", (_, _) -> {});

        this.style = style;
    }

    override function on_input(action_id:Hash, action:ScriptOnInputAction):Bool {
        if (selected) {
            var input_text = null;
            if (action_id == Const.ACTION_TEXT) {
                var action_text:String = untyped action.text;

                if (action_text == "\n" || action_text == "\r")
                    return true;

                var hex = LuaString.gsub(action_text, "(.)", c -> {
                    return LuaString.format("%02X%s", LuaString.byte(c), "");
                });

                if (LuaString.match(hex, "EF9C8[0-3]") == null) {
                    if (allowed_characters == null || LuaString.match(action_text, allowed_characters) != null) {
                        input_text = value + action_text;
                        if (max_length != null)
                            input_text = Utf8.sub(input_text, 1, max_length);
                    } else {
                        on_input_wrong.trigger([context, action_text]);
                        invoke_style("on_input_wrong", [this, button.node]);
                    }
                    marked_value = "";
                }
            }

            if (action_id == Const.ACTION_MARKED_TEXT) {
                var action_text:String = untyped action.text;
                marked_value = action_text != null ? action_text : "";
                if (max_length != null)
                    marked_value = Utf8.sub(marked_value, 1, max_length);
            }

            if (action_id == Const.ACTION_BACKSPACE && (action.pressed || action.repeated))
                input_text = Utf8.sub(value, 1, -2);

            if (action_id == Const.ACTION_ENTER && action.released) {
                unselect();
                return true;
            }

            if (action_id == Const.ACTION_BACK && action.released) {
                unselect();
                return true;
            }

            if (action_id == Const.ACTION_ESC && action.released) {
                unselect();
                return true;
            }

            if (input_text != null) {
                set_text(input_text);
                return true;
            }
        }

        return selected;
    }

    override function on_focus_lost() {
        unselect();
    }

    /**
        Set text for input field

        @param input_text The string to apply for input field
    **/
    public function set_text(?input_text:String):Void {
        if (input_text != null)
            value = input_text;

        var current_value = value + marked_value;

        if (current_value != this.current_value) {
            this.current_value = current_value;

            var masked_value:String = null, masked_marked_value:String = null;
            if (keyboard_type == KEYBOARD_TYPE_PASSWORD) {
                masked_value = mask_text(value, style["MASK_DEFAULT_CHAR"]);
                masked_marked_value = mask_text(marked_value, style["MASK_DEFAULT_CHAR"]);
            }

            var value = masked_value != null ? masked_value : this.value;
            var marked_value = masked_marked_value != null ? masked_marked_value : this.marked_value;
            is_empty = value.length == 0 && marked_value.length == 0;

            var final_text = value + marked_value;
            text.set_to(final_text);

            text_width = text.get_text_width(value);
            marked_text_width = text.get_text_width(marked_value);
            total_width = text_width + marked_text_width;

            on_input_text.trigger([context, final_text]);
            if (final_text.length == 0)
                on_input_empty.trigger([context, final_text]);
            if (max_length != null && final_text.length == max_length)
                on_input_full.trigger([context, final_text]);
        }
    }

    /**
        Return current input field text

        @return The current input field text
    **/
    public function get_text():String
        return value + marked_value;

    /**
        Reset current input selection and return previous value
    **/
    public function reset_changes():Void {
        set_text(previous_value);
        unselect();
    }

    private static function mask_text(text:String, ?mask:String = "*"):String {
        var masked_text = "";
        for (uchar in new HaxeIterator(Utf8.gmatch(text, ".")))
            masked_text += mask;
        return masked_text;
    }

    private function select():Void {
        Gui.reset_keyboard();
        marked_value = "";
        if (!selected) {
            increased_input_priority = true;
            button.increased_input_priority = true;
            previous_value = value;
            selected = true;

            Gui.show_keyboard(keyboard_type, false);
            on_input_select.trigger([context]);

            invoke_style("on_select", [this, this.button.node]);
        }
    }

    private function unselect():Void {
        Gui.reset_keyboard();
        marked_value = "";
        if (selected) {
            increased_input_priority = false;
            button.increased_input_priority = false;
            selected = false;

            Gui.hide_keyboard();
            on_input_unselect.trigger([context]);

            invoke_style("on_unselect", [this, this.button.node]);
        }
    }

    private function clear_and_select():Void {
        if (style["IS_LONGTAP_ERASE"])
            set_text("");

        select();
    }
}
