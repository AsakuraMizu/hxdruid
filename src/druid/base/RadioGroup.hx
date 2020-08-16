package druid.base;

import haxe.Constraints.Function;
import druid.types.NodeOrString;

/**
    Radio group
**/
class RadioGroup<T:{}> extends Component<T> {
    private var checkboxes:Array<Checkbox<T>> = [];

    public var on_radio_click(default, null):Event<(T, RadioGroup<T>, Int) -> Void>;

    /**
        Component constructor

        @param nodes Array of gui nodes and trigger nodes
        @param callback Radio group callback
    **/
    public function new(
            nodes:Array<{node:NodeOrString, ?click_node:NodeOrString}>, ?callback:(T, RadioGroup<T>, Int) -> Void
        ) {
        name = "RadioGroup";

        on_radio_click = new Event(callback);

        for (i => v in nodes.keyValueIterator()) {
            var checkbox = new Checkbox(v.node, (context, state) -> {
                on_checkbox_click(i);
            }, v.click_node);
            add_child(checkbox);
            checkboxes.push(checkbox);
        }
    }

    private function on_checkbox_click(index:Int):Void {
        for (i => v in checkboxes.keyValueIterator())
            v.set_state(i == index, true);

        on_radio_click.trigger([context, this, index]);
    }

    /**
        Set radio group state

        @param states Index in radio group
    **/
    public function set_state(index:Int):Void {
        on_checkbox_click(index);
    }

    /**
        Get radio group state

        @return Index in radio group
    **/
    public function get_state():Int {
        var result = -1;

        for (i => v in checkboxes.keyValueIterator()) {
            if (v.state) {
                result = i;
                break;
            }
        }

        return result;
    }
}