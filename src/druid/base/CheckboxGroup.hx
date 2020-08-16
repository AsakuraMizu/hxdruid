package druid.base;

import druid.types.NodeOrString;

/**
    Checkbox group
**/
class CheckboxGroup<T:{}> extends Component<T> {
    private var checkboxes:Array<Checkbox<T>> = [];

    public var on_checkbox_click(default, null):Event<(T, CheckboxGroup<T>, Int) -> Void>;

    /**
        Component constructor

        @param nodes Array of gui nodes and trigger nodes
        @param callback Checkbox group callback
    **/
    public function new(
            nodes:Array<{node:NodeOrString, ?click_node:NodeOrString}>, ?callback:(T, CheckboxGroup<T>, Int) -> Void
        ) {
        name = "CheckboxGroup";

        on_checkbox_click = new Event(callback);

        for (i => v in nodes.keyValueIterator()) {
            var checkbox = new Checkbox(v.node, (context, state) -> {
                on_checkbox_click.trigger([context, this, i]);
            }, v.click_node);
            add_child(checkbox);
            checkboxes.push(checkbox);
        }
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