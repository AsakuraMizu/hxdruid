package druid.base;

import defold.Gui;
import defold.types.Vector3;
import defold.types.Vector4;
import druid.types.ComponentStyle;
import druid.types.NodeOrString;

/**
    Basic progress bar component
**/
class Progress<T:{}> extends Component<T> {
    private var node:GuiNode;
    private var key:Const.SIDE;
    private var scale:Vector3;
    private var size:Vector3;
    private var max_size:Float;
    private var slice:Vector4;
    private var slice_size:Float;

    private var last_value:Float;
    private var target:Float;
    private var target_callback:(T, Float) -> Void;
    private var steps:Array<Float>;
    private var step_callback:(T, Float) -> Void;

    /**
        On progress bar change callback
    **/
    public var on_change(default, null):Event<(T, Float) -> Void>;

    /**
        Component constructor

        @param node Progress bar fill node or node name
        @param key Progress bar direction
        @param init_value Initial value of progress bar
    **/
    public function new(node:NodeOrString, key:Const.SIDE, ?init_value:Float = 1) {
        name = "Progress";
        interest = [Const.ON_UPDATE];

        this.key = key;
        this.node = get_node(node);

        scale = Gui.get_scale(this.node);
        size = Gui.get_size(this.node);
        max_size = switch key {case X: size.x; case Y: size.y;};
        slice = Gui.get_slice9(this.node);
        slice_size = switch key {case X: slice.x + slice.z; case Y: slice.y + slice.w;};

        on_change = new Event();

        set_to(init_value);
    }

    override function on_style_change(?style:ComponentStyle) {
        if (style == null)
            style = [];

        Helper.null_default(style, "SPEED", 5);
        Helper.null_default(style, "MIN_DELTA", .005);

        this.style = style;
    }

    override function update(dt:Float) {
        if (target != null) {
            var prev_value = last_value;
            var step = Math.abs(last_value - target) * style["SPEED"] * dt;
            step = Math.max(step, style["MIN_DELTA"]);
            set_to(Helper.step(last_value, target, step));

            if (last_value == target) {
                check_steps(prev_value, target, target);

                if (target_callback != null)
                    target_callback(context, target);

                target = null;
            }
        }
    }

    /**
        Fill a progress bar and stop progress animation
    **/
    public function fill():Void
        set_bar_to(1, true);

    /**
        Empty a progress bar
    **/
    public function empty():Void
        set_bar_to(0, true);

    /**
        Instant fill progress bar to value
        
        @param to Progress bar value, from 0 to 1
    **/
    public function set_to(to:Float):Void {
        to = Helper.clamp(to, 0, 1);
        set_bar_to(to);
    }

    /**
        Return current progress bar value
    **/
    public function get():Float
        return last_value;

    /**
        Set points on progress bar to fire the callback

        @param steps Array of progress bar values
        @param callback Callback on intersect step value
    **/
    public function set_steps(steps:Array<Float>, callback:(T, Float) -> Void):Void {
        this.steps = steps;
        step_callback = callback;
    }

    /**
        Start animation of a progress bar

        @param to value between 0..1
        @param callback Callback on animation ends
    **/
    public function to(to:Float, ?callback:(T, Float) -> Void):Void {
        to = Helper.clamp(to, 0, 1);
        var value = Helper.round(to, 5);
        if (value != last_value) {
            target = value;
            target_callback = callback;
        } else {
            if (callback != null)
                callback(context, to);
        }
    }

    private function check_steps(from:Float, to:Float, ?exactly:Float):Void {
        if (steps == null || step_callback == null)
            return;

        for (i in steps) {
            if (Math.min(from, to) < i && i < Math.max(from, to))
                step_callback(context, i);
            if (exactly == i)
                step_callback(context, i);
        }
    }

    private function set_bar_to(set_to:Float, ?is_silent:Bool = false) {
        var prev_value = last_value;
        last_value = set_to;

        var total_width = set_to * max_size;

        var scale = Math.min(total_width / slice_size, 1);
        var size = Math.max(total_width, slice_size);

        switch key {
            case X: {
                this.scale.x = scale;
                Gui.set_scale(node, this.scale);
                this.size.x = size;
                Gui.set_size(node, this.size);
            }
            case Y: {
                this.scale.y = scale;
                Gui.set_scale(node, this.scale);
                this.size.y = size;
                Gui.set_size(node, this.size);
            }
        }

        if (!is_silent) {
            on_change.trigger([context, set_to]);
            check_steps(prev_value, set_to);
        }
    }
}