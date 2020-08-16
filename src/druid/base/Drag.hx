package druid.base;

import haxe.ds.Either;
import lua.Table;
import defold.Gui;
import defold.Vmath;
import defold.support.ScriptOnInputAction;
import defold.types.Hash;
import defold.types.Vector3;
import druid.types.ComponentStyle;
import druid.types.NodeOrString;

/**
    Component to handle drag action on node

    Drag have correct handling for multitouch and swap
    touched while dragging. Drag will be processed even
    the cursor is outside of node, if drag is already started
**/
class Drag<T:{}> extends Component<T> {
    private var node:GuiNode;
    private var click_zone:GuiNode;

    private var dx:Float = 0;
    private var dy:Float = 0;
    private var touch_id:Int = 0;
    private var x:Float = 0;
    private var y:Float = 0;
    private var is_touch:Bool = false;
    private var is_drag:Bool = false;
    private var touch_start_pos:Vector3 = Vmath.vector3();

    /**
        Is drag component process vertical dragging. Default - true
    **/
    public var can_x:Bool = true;

    /**
        Is drag component process horizontal. Default - true
    **/
    public var can_y:Bool = true;

    /**
        Event on touch start (self)
    **/
    public var on_touch_start(default, null):Event<T -> Void>;

    /**
        Event on touch end (self)
    **/
    public var on_touch_end(default, null):Event<T -> Void>;

    /**
        Event on drag start (self)
    **/
    public var on_drag_start(default, null):Event<T -> Void>;

    /**
        Event on drag progress (self, dx, dy)
    **/
    public var on_drag(default, null):Event<(T, Float, Float) -> Void>;

    /**
        Event on drag end (self)
    **/
    public var on_drag_end(default, null):Event<T -> Void>;

    /**
        Component constructor

        @param node GUI node to detect dragging
        @param callback Callback for on_drag_event(self, dx, dy)
    **/
    public function new(node:NodeOrString, ?callback:(T, Float, Float) -> Void) {
        name = "Drag";
        interest = [Const.ON_INPUT_HIGH];

        this.node = get_node(node);

        on_touch_start = new Event();
        on_touch_end = new Event();
        on_drag_start = new Event();
        on_drag = new Event(callback);
        on_drag_end = new Event();
    }

    override function on_input(action_id:Hash, action:ScriptOnInputAction):Bool {
        if (action_id != Const.ACTION_TOUCH && action_id != Const.ACTION_MULTITOUCH)
            return false;

        if (!Helper.is_enabled(node))
            return false;

        var is_pick = Gui.pick_node(node, action.x, action.y);
        if (click_zone != null)
            is_pick = is_pick && Gui.pick_node(click_zone, action.x, action.y);

        if (!is_pick && !is_drag) {
            end_touch();
            return false;
        }

        var touch = find_touch(action_id, action, touch_id);
        if (touch == null)
            return false;

        switch touch {
            case Left(v): {
                if (v.pressed && !is_touch)
                    start_touch(v);

                if (v.released && is_touch)
                    end_touch();

                if (is_touch)
                    process_touch(v);
            }
            case Right(v): {
                touch_id = v.id;

                if (v.pressed && !is_touch)
                    start_touch(v);

                if (v.released && is_touch)
                    on_touch_release(action_id, action);

                if (is_touch)
                    process_touch(v);
            }
        }

        dx = 0;
        dy = 0;

        var touch_modified = find_touch(action_id, action, touch_id);

        if (touch_modified != null) {
            switch touch_modified {
                case Left(v): {
                    if (is_drag) {
                        dx = v.x - x;
                        dy = v.y - y;
                    }
                    x = v.x;
                    y = v.y;
                }
                case Right(v): {
                    if (is_drag) {
                        dx = v.x - x;
                        dy = v.y - y;
                    }
                    x = v.x;
                    y = v.y;
                }
            }
        }

        if (is_drag)
            on_drag.trigger([context, dx, dy]);

        return is_drag;
    }

    override function on_input_interrupt() {
        if (is_drag || is_touch)
            end_touch();
    }

    override function on_style_change(style:ComponentStyle) {
        if (style == null)
            style = [];

        Helper.null_default(style, "DRAG_DEADZONE", 10);
        
        this.style = style;
    }

    /**
        Strict drag click area. Useful for
        restrict events outside stencil node

        @param zone Gui node
    **/
    public function set_click_zone(zone:NodeOrString):Void
        click_zone = get_node(zone);

    private function start_touch<T:{x:Float, y:Float}>(touch:T):Void {
        is_touch = true;
        is_drag = false;

        x = touch_start_pos.x = touch.x;
        y = touch_start_pos.y = touch.y;

        on_touch_start.trigger([context]);
    }

    private function end_touch():Void {
        if (is_drag)
            on_drag_end.trigger([context]);

        is_drag = false;
        is_touch = false;
        on_touch_end.trigger([context]);
        increased_input_priority = true;
        touch_id = 0;
    }

    private function process_touch<T:{x:Float, y:Float}>(touch:T):Void {
        if (!can_x)
            touch_start_pos.x = touch.x;
        if (!can_y)
            touch_start_pos.y = touch.y;

        var distance = Helper.distance(touch.x, touch.y, touch_start_pos.x, touch_start_pos.y);
        if (!is_drag && style["DRAG_DEADZONE"] <= distance) {
            is_drag = true;
            on_drag_start.trigger([context]);
            increased_input_priority = true;
        }
    }

    private function find_touch(action_id:Hash, action:ScriptOnInputAction, touch_id:Int):Either<ScriptOnInputAction, ScriptOnInputActionTouch> {
        var act = Helper.is_mobile() ? Const.ACTION_MULTITOUCH : Const.ACTION_TOUCH;

        if (action_id != act)
            return null;

        if (action.touch != null) {
            var touch = action.touch;
            for (i in Table.toArray(touch))
                if (i.id == touch_id)
                    return Right(i);
            return Right(touch[1]);
        } else {
            return Left(action);
        }
    }

    private function on_touch_release(action_id:Hash, action:ScriptOnInputAction):Void {
        var arr = Table.toArray(action.touch);
        if (arr.length >= 2) {
            var next_touch:ScriptOnInputActionTouch = null;
            for (i in arr) {
                if (!i.released) {
                    next_touch = i;
                    break;
                }
            }

            if (next_touch != null) {
                x = next_touch.x;
                y = next_touch.y;
                touch_id = next_touch.id;
            } else {
                end_touch();
            }
        } else if (arr.length == 1) {
            end_touch();
        }
    }
}