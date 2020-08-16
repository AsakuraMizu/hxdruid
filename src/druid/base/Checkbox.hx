package druid.base;

import druid.types.ComponentStyle;
import haxe.Constraints.Function;
import defold.Gui;
import druid.types.DruidStyle;
import druid.types.NodeOrString;

/**
    Druid checkbox component
**/
class Checkbox<T:{}> extends Component<T> {
    private var node:GuiNode;
    private var click_node:GuiNode;
    private var button:Button<T>;

    /**
        Checkbox state
    **/
    public var state(default, null):Bool;

    /**
        On change state callback
    **/
    public var on_change_state(default, null):Event;

    /**
        Component constructor

        @param node Gui node
        @param callback Checkbox callback
        @param click_node Trigger node, by default equals to node
    **/
    public function new(node:NodeOrString, ?callback:Function, ?click_node:NodeOrString) {
        name = "Checkbox";

        this.node = get_node(node);
        this.click_node = get_node(click_node);

        button = new Button(this.click_node != null ? this.click_node : this.node, on_click);

        on_change_state = new Event(callback);
        set_state(false, true);
    }

    override function on_style_change(style:ComponentStyle) {
        if (style == null)
            style = [];

        Helper.null_default(style, "on_change_state", (_, node, state) -> { Gui.set_enabled(node, state); });
    }

    /**
        Set checkbox state
    **/
    public function set_state(state:Bool, ?is_silent:Bool = false):Void {
        if (state != this.state) {
            this.state = state;
            invoke_style("on_change_state", [this, node, state]);

            if (!is_silent) {
                on_change_state.trigger([context, state]);
            }
        }
    }

    private function on_click(context:T, params:Dynamic, button:Button<T>) {
        set_state(!state);
    }
}