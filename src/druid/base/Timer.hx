package druid.base;

import defold.Gui;
import druid.types.NodeOrString;

/**
    Component to handle GUI timers
    Timer updating by game delta time. If game is not focused -
    timer will be not updated
**/
class Timer<T:{}> extends Component<T> {
    private var node:GuiNode;
    private var from:Float;
    private var value:Float;
    private var target:Float;
    private var last_value:Float;
    private var temp:Float;
    private var is_on:Bool;

    /**
        On timer tick callback. Fire every second
    **/
    public var on_tick(default, null):Event<(T, Float) -> Void>;

    /**
        On timer change enabled state callback
    **/
    public var on_set_enabled(default, null):Event<(T, Bool) -> Void>;

    /**
        On timer end callback
    **/
    public var on_timer_end(default, null):Event<T -> Void>;

    /**
        Component constructor

        @param node Gui text node
        @param seconds_from Start timer value in seconds
        @param seconds_to End timer value in seconds
        @param callback Function on timer end
    **/
    public function new(node:NodeOrString, seconds_from:Float, ?seconds_to:Float = 0, ?callback:T -> Void) {
        name = "Timer";
        interest = [Const.ON_UPDATE];

        this.node = get_node(node);
        seconds_from = Std.int(Math.max(seconds_from, 0));
        seconds_to = Std.int(Math.max(seconds_to, 0));

        on_tick = new Event();
        on_set_enabled = new Event();
        on_timer_end = new Event(callback);

        set_to(seconds_from);
        set_interval(seconds_from, seconds_to);

        if (seconds_to - seconds_from == 0) {
            set_state(false);
            on_timer_end.trigger([context]);
        }
    }

    override function update(dt:Float) {
        if (!is_on)
            return;

        temp += dt;
        var dist = Math.min(1, Math.abs(value - target));

        if (temp > dist) {
            temp -= dist;
            value = Helper.step(value, target, 1);
            set_to(value);

            on_tick.trigger([context, value]);

            if (value == target) {
                set_state(false);
                on_timer_end.trigger([context]);
            }
        }
    }

    /**
        Set text to text field

        @param set_to Value in seconds
    **/
    public function set_to(set_to:Float):Void {
        last_value = set_to;
        Gui.set_text(node, Helper.Formats.second_string_min(Std.int(set_to)));
    }

    /**
        Called when update

        @param is_on Timer enable state
    **/
    public function set_state(is_on:Bool):Void {
        this.is_on = is_on;
        on_set_enabled.trigger([context, is_on]);
    }

    /**
        Set time interval

        @param from Start time in seconds
        @param to Target time in seconds
    **/
    public function set_interval(from:Float, to:Float):Void {
        value = this.from = from;
        temp = 0;
        target = to;
        set_state(true);
        set_to(from);
    }
}