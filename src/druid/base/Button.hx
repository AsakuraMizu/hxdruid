package druid.base;

import haxe.Constraints.Function;
import defold.Gui;
import druid.types.NodeOrString;

class Button<T:{}, PT:{}> extends Component<T> {
    private var node:GuiNode;
    private var anim_node:GuiNode;
    private var params:PT;

    public function new(node:NodeOrString, ?callback:Function, ?params:PT, ?anim_node:NodeOrString) {
        name = "Button";
        interest = [Const.ON_INPUT];

        this.node = get_node(node);
        if (anim_node == null) {
            this.anim_node = this.node;
        } else {
            this.anim_node = get_node(anim_node);
        }

        this.params = params;
        
    }
}