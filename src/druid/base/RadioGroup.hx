package druid.base;

import druid.types.DruidStyle;
import druid.types.NodeOrString;

/**
    Radio group
**/
class RadioGroup<T:{}> extends Component<T> {
    private var checkboxes:Array<Checkbox<T>> = [];

    public var on_radio_click(default, null):Event<(T, Int) -> Void>;

    /**
        Component constructor

        @param nodes Array of gui nodes and trigger nodes
        @param callback Radio group callback
    **/
    public function new(
            nodes:Array<{node:NodeOrString, ?click_node:NodeOrString}>, ?callback:(T, Int) -> Void
        ) {
        name = "RadioGroup";

        for (i => v in nodes.keyValueIterator()) {
            var checkbox = new Checkbox(v.node, (context, state) -> {
                on_checkbox_click(i);
            }, v.click_node);
            checkboxes.push(checkbox);
        }

        on_radio_click = new Event(callback);
    }

    override function init(druid:Druid<T>, context:T, ?druid_style:DruidStyle) {
        super.init(druid, context, druid_style);

        for (i in checkboxes)
            add_child(i);
    }

    private function on_checkbox_click(index:Int):Void {
        for (i => v in checkboxes.keyValueIterator())
            v.set_state(i == index, true);

        on_radio_click.trigger([context, index]);
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