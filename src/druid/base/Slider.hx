package druid.base;

import defold.Gui;
import defold.Vmath;
import defold.support.ScriptOnInputAction;
import defold.types.Hash;
import defold.types.Vector3;
import druid.types.NodeOrString;

/**
    Druid slider component
**/
class Slider<T:{}> extends Component<T> {
    private var node:GuiNode;
    private var start_pos:Vector3;
    private var pos:Vector3;
    private var target_pos:Vector3;
    private var end_pos:Vector3;
    private var dist:Vector3;
    private var is_drag:Bool = false;
    private var value:Float = 0;

    /**
        Slider steps. Pin node will apply closest step position
    **/
    public var steps:Array<Float>;

    public var on_change_value:Event<(T, Float) -> Void>;

    /**
        Component constructor

        @param node Gui pin node
        @param dist Length between start and end position
        @param callback On slider change callback
    **/
    public function new(node:NodeOrString, dist:Vector3, ?callback:(T, Float) -> Void) {
        name = "Slider";
        interest = [Const.ON_INPUT_HIGH];

        this.node = get_node(node);

        target_pos = pos = start_pos = Gui.get_position(this.node);
        this.dist = dist;

        end_pos = start_pos + dist;

        on_change_value = new Event(callback);
    }

    override function on_input(action_id:Hash, action:ScriptOnInputAction):Bool {
        if (action_id != Const.ACTION_TOUCH)
            return false;

        if (Gui.pick_node(node, action.x, action.y) && action.pressed) {
            pos = Gui.get_position(node);
            is_drag = true;
        }

        if (is_drag && !action.pressed) {
            pos += Vmath.vector3(action.dx, action.dy, 0);
            var prev_pos = target_pos;
            target_pos = Vmath.vector3(
                Helper.clamp(pos.x, start_pos.x, end_pos.x),
                Helper.clamp(pos.y, start_pos.y, end_pos.y),
                0
            );

            if (prev_pos != target_pos) {
                var prev_value = value;
                
                value = Vmath.project(target_pos - start_pos, dist);

                if (steps != null) {
                    var closest_dist:Float = Math.POSITIVE_INFINITY;
                    var closest:Float = null;

                    for (i in steps) {
                        var dist = Math.abs(value - i);
                        if (dist < closest_dist) {
                            closest = i;
                            closest_dist = dist;
                        }
                    }

                    if (closest != null)
                        value = closest;
                }

                if (prev_value != value)
                    on_change_value.trigger([context, value]);
            }

            set_position(value);
        }
        
        if (action.released)
            is_drag = false;

        return is_drag;
    }

    /**
        Set value for slider

        @param value Value from 0 to 1
        @param is_silent Don't trigger event if true
    **/
    public function set(value:Float, ?is_slient:Bool = false):Void {
        value = Helper.clamp(value, 0, 1);
        set_position(value);
        this.value = value;
        if (!is_slient)
            on_change_value.trigger([context, value]);
    }

    private function set_position(value:Float):Void {
        value = Helper.clamp(value, 0, 1);
        Gui.set_position(node, Vmath.lerp(value, start_pos, end_pos));
    }
}