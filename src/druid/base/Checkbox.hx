package druid.base;

import defold.Gui;
import druid.types.ComponentStyle;
import druid.types.DruidStyle;
import druid.types.NodeOrString;

/**
    Druid checkbox component
**/
class Checkbox<T:{}> extends Component<T> {
    private var node:GuiNode;
    private var click_node:GuiNode;

    /**
        Checkbox state
    **/
    public var state(default, null):Bool;

    /**
        On change state callback
    **/
    public var on_change_state(default, null):Event<(T, Bool) -> Void>;

    /**
        Component constructor

        @param node Gui node
        @param callback Checkbox callback
        @param click_node Trigger node, by default equals to node
    **/
    public function new(node:NodeOrString, ?callback:(T, Bool) -> Void, ?click_node:NodeOrString) {
        name = "Checkbox";

        this.node = get_node(node);
        this.click_node = get_node(click_node);

        on_change_state = new Event(callback);
    }

    override function init(druid:Druid<T>, context:T, ?druid_style:DruidStyle) {
        super.init(druid, context, druid_style);

        add_child(new Button(this.click_node != null ? this.click_node : this.node, on_click));
        set_state(false, true);
    }

    override function on_style_change(?style:ComponentStyle) {
        if (style == null)
            style = [];

        Helper.null_default(style, "on_change_state", (_, node, state) -> {});

        this.style = style;
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

    private function on_click(context:T) {
        set_state(!state);
    }
}