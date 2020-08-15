package druid.base;

import defold.types.Hash;
import defold.support.ScriptOnInputAction;
import haxe.Constraints.Function;
import defold.Gui;
import druid.types.NodeOrString;

/**
    Component to handle hover node interaction
**/
class Hover<T:{}> extends Component<T> {
    private var node:GuiNode;
    private var click_zone:GuiNode;

    private var is_hovered:Bool = false;
    private var is_mouse_hovered:Bool = false;

    /**
        current hover enabled state
    **/
    public var is_enabled(default, set):Bool = true;


    /**
        On hover callback (Touch pressed)
    **/
    public var on_hover(default, null):Event;

    /**
        On mouse hover callback (Touch over without action_id)
    **/
    public var on_mouse_hover(default, null):Event;

    /**
        Component constructor

        @param node Gui node
        @param on_hover_callback Hover callback
    **/
    public function new(node: NodeOrString, ?on_hover_callback:Function) {
        name = "Hover";
        interest = [Const.ON_INPUT];

        this.node = get_node(node);

        on_hover = new Event(on_hover_callback);
        on_mouse_hover = new Event();
    }
    
    /**
        Set hover state

        @param state The hover state
    **/
    public function set_hover(state:Bool):Void {
        if (is_hovered != state) {
            is_hovered = state;
            on_hover.trigger([context, state]);
        }
    }
    
    /**
        Set hover state

        @param state The mouse hover state
    **/
    public function set_mouse_hover(state:Bool):Void {
        if (is_mouse_hovered != state) {
            is_mouse_hovered = state;
            on_hover.trigger([context, state]);
        }
    }

    override function on_input(action_id:Hash, action:ScriptOnInputAction):Bool {
        if (action_id != Const.ACTION_TOUCH && action_id != null)
            return false;

        if (action_id == null && Helper.is_mobile())
            return false;

        if (!Helper.is_enabled(node) || !is_enabled)
            return false;

        var is_pick = Gui.pick_node(node, action.x, action.y);
        if (click_zone != null)
            is_pick = is_pick && Gui.pick_node(click_zone, action.x, action.y);

        var hover_function = action_id == null ? set_hover : set_mouse_hover;

        if (!is_pick) {
            hover_function(false);
            return false;
        }

        if (action.released)
            hover_function(false);
        else
            hover_function(true);

        return false;
    }

    override function on_input_interrupt():Void
        set_hover(false);

    /**
        Strict hover click area. Useful for
        no click events outside stencil node

        @param zone Gui node
    **/
    public function set_click_zone(zone:NodeOrString):GuiNode
        return get_node(zone);

    public function set_is_enabled(state:Bool):Bool {
        if (!state) {
            if (is_hovered)
                set_hover(false);
            if (is_mouse_hovered)
                set_mouse_hover(false);
        }

        return state;
    }
}