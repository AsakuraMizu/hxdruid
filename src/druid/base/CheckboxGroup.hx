package druid.base;

import druid.types.DruidStyle;
import druid.types.NodeOrString;

/**
    Checkbox group
**/
class CheckboxGroup<T:{}> extends Component<T> {
    private var checkboxes:Array<Checkbox<T>> = [];

    public var on_checkbox_click(default, null):Event<(T, Int) -> Void>;

    /**
        Component constructor

        @param nodes Array of gui nodes and trigger nodes
        @param callback Checkbox group callback
    **/
    public function new(
            nodes:Array<{node:NodeOrString, ?click_node:NodeOrString}>, ?callback:(T, Int) -> Void
        ) {
        name = "CheckboxGroup";

        for (i => v in nodes.keyValueIterator()) {
            var checkbox = new Checkbox(v.node, (context, state) -> {
                on_checkbox_click.trigger([context, i]);
            }, v.click_node);
            checkboxes.push(checkbox);
        }

        on_checkbox_click = new Event(callback);
    }

    override function init(druid:Druid<T>, context:T, ?druid_style:DruidStyle) {
        super.init(druid, context, druid_style);

        for (i in checkboxes)
            add_child(i);
    }

    /**
        Set checkbox group state

        @param states Array of checkbox state
    **/
    public function set_state(states:Array<Bool>):Void {
        for (i => state in states.keyValueIterator())
            if (checkboxes[i] != null)
                checkboxes[i].set_state(state, true);
    }

    /**
        Get checkbox group state

        @return Array of checkboxes state
    **/
    public function get_state():Array<Bool>
        return [for (i in checkboxes) i.state];
}