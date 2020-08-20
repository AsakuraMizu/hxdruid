package druid.base;

import defold.Gui;
import defold.Vmath;
import defold.support.ScriptOnInputAction;
import defold.types.Hash;
import defold.types.Vector3;
import druid.types.ComponentStyle;
import druid.types.NodeOrString;

/**
    Component to handle swipe gestures on node
**/
class Swipe<T:{}> extends Component<T> {
    private var node:GuiNode;
    private var click_zone:GuiNode;
    private var swipe_start_time:Float;
    private var start_pos:Vector3 = Vmath.vector3();

    /**
        Trigger on swipe event
    **/
    public var on_swipe(default, null):Event<(T, Const.SWIPE, Float, Float) -> Void>;

    /**
        Component constructor

        @param node Gui node
        @param callback Swipe callback for on_swipe_end event
    **/
    public function new(node:NodeOrString, ?callback:(T, Const.SWIPE, Float, Float) -> Void) {
        name = "Swipe";
        interest = [Const.ON_INPUT];

        this.node = get_node(node);

        on_swipe = new Event(callback);
    }

    override function on_style_change(?style:ComponentStyle) {
        if (style == null)
            style = [];

        var set:(String, Dynamic) -> Void = Helper.null_default.bind(style, _, _);

        set("SWIPE_TIME", .4);
        set("SWIPE_THRESHOLD", 50);
        set("SWIPE_TRIGGER_ON_MOVE", false);

        this.style = style;
    }

    override function on_input(action_id:Hash, action:ScriptOnInputAction):Bool {
        if (action_id != Const.ACTION_TOUCH)
            return false;

        if (!Helper.is_enabled(node))
            return false;

        var is_pick = Gui.pick_node(node, action.x, action.y);
        if (click_zone != null)
            is_pick = is_pick && Gui.pick_node(click_zone, action.x, action.y);

        if (!is_pick) {
            reset_swipe();
            return false;
        }

        if (swipe_start_time != null && (style["SWIPE_TRIGGER_ON_MOVE"] || action.released))
            check_swipe(action);

        if (action.pressed)
            start_swipe(action);

        if (action.released)
            reset_swipe();

        return false;
    }

    override function on_input_interrupt():Void
        reset_swipe();

    /**
        Strict button click area. Useful for
        no click events outside stencil node

        @param zone Gui node
    **/
    public function set_click_zone(zone:NodeOrString):Void
        click_zone = get_node(zone);

    private function start_swipe(action:ScriptOnInputAction):Void {
        swipe_start_time = Socket.gettime();
        start_pos = Vmath.vector3(action.x, action.y, 0);
    }

    private function reset_swipe():Void
        swipe_start_time = null;

    private function check_swipe(action:ScriptOnInputAction):Void {
        var dx = action.x - start_pos.x, dy = action.y - start_pos.y;
        var dist = Helper.distance(start_pos.x, start_pos.y, action.x, action.y);
        var delta_time = Socket.gettime() - swipe_start_time;
        var is_swipe = style["SWIPE_THRESHOLD"] <= dist && delta_time <= style["SWIPE_TIME"];

        if (is_swipe) {
            var is_x_swipe = Math.abs(dx) >= Math.abs(dy);
            var swipe_side:Const.SWIPE = null;

            if (is_x_swipe && dx > 0)
                swipe_side = Const.SWIPE.RIGHT;
            if (is_x_swipe && dx < 0)
                swipe_side = Const.SWIPE.LEFT;
            if (!is_x_swipe && dy > 0)
                swipe_side = Const.SWIPE.UP;
            if (!is_x_swipe && dy < 0)
                swipe_side = Const.SWIPE.DOWN;

            on_swipe.trigger([context, swipe_side, dist, delta_time]);
            reset_swipe();
        }
    }
}
