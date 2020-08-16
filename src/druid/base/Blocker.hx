package druid.base;

import defold.Gui;
import defold.support.ScriptOnInputAction;
import defold.types.Hash;

/**
    Component to block input on specify zone by node
**/
class Blocker<T:{}> extends Component<T> {
    private var node:GuiNode;

    /**
        Blocker enabled state
    **/
    public var is_enabled(default, set):Bool = true;

    /**
        On release button callback
    **/
    public var on_click(default, null):Event<T -> Void>;

    /**
        On enable/disable callback
    **/
    public var on_enable_change(default, null):Event<(T, Bool) -> Void>;

    public function new(node:GuiNode) {
        name = "Blocker";
        interest = [Const.ON_INPUT];

        this.node = node;

        on_click = new Event();
        on_enable_change = new Event();
    }

    override function on_input(action_id:Hash, action:ScriptOnInputAction):Bool {
        if (action_id != Const.ACTION_TOUCH && action_id != Const.ACTION_MULTITOUCH && action_id != null)
            return false;

        if (!is_enabled)
            return false;

        if (Gui.pick_node(node, action.x, action.y)) {
            on_click.trigger([context]);
            return true;
        }

        return false;
    }

    public function set_is_enabled(state:Bool):Bool {
        on_enable_change.trigger([context, state]);
        Gui.set_enabled(node, state);
        return state;
    }
}