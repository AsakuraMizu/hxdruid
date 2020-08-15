package druid.base;

import haxe.Constraints.Function;
import defold.Gui;
import druid.types.NodeOrString;

class Checkbox<T:{}> extends Component<T> {
    private var node:GuiNode;
    public function new(node:NodeOrString, callback:Function, click_node:NodeOrString) {
        this.node = get_node(node);
        var click_node = get_node(click_node);

    }
}