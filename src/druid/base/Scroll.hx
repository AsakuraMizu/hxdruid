package druid.base;

import defold.Gui;
import defold.Vmath;
import defold.types.Vector3;
import defold.types.Vector4;
import druid.types.ComponentStyle;
import druid.types.DruidStyle;
import druid.types.NodeOrString;

/**
    Component to handle scroll content.
    Scroll consist from two nodes: scroll parent and scroll input
    Scroll input the user input zone, it's static
    Scroll parent the scroll moving part, it will change position.
    Setup initial scroll size by changing scroll parent size. If scroll parent
    size will be less than scroll_input size, no scroll is available. For scroll
    parent size should be more than input size
**/
class Scroll<T:{}> extends Component<T> {
    private var view_node:GuiNode;
    private var content_node:GuiNode;
    private var position:Vector3;
    private var target_position:Vector3;
    private var inertion:Vector3 = Vmath.vector3();
    private var available_pos:Vector4;
    private var available_pos_extra:Vector4;
    private var available_size:Vector3;
    private var available_size_extra:Vector3;
    private var is_animate:Bool = false;
    private var selected:Int;
    private var points:Array<Vector3>;
    private var drag:Drag<T>;

    /**
        Scroll inert
    **/
    public var is_inert:Bool;

    /**
        On scroll move callback
    **/
    public var on_scroll(default, null):Event<(T, Vector3) -> Void>;

    /**
        On scroll_to function callback
    **/
    public var on_scroll_to(default, null):Event<(T, Vector3, Bool) -> Void>;

    /**
        On scroll_to_index function callback
    **/
    public var on_point_scroll(default, null):Event<(T, Int, Vector3) -> Void>;

    /**
        Component constructor

        @param view_node GUI view scroll node
        @param content_node GUI content scroll node
    **/
    public function new(view_node:NodeOrString, content_node:NodeOrString) {
        name = "Scroll";
        interest = [Const.ON_UPDATE];

        this.view_node = get_node(view_node);
        this.content_node = get_node(content_node);
        position = Gui.get_position(this.content_node);
        target_position = Vmath.vector3(position);

        drag = new Drag(view_node, on_scroll_drag);
        drag.on_touch_start.subscribe(on_touch_start);
        drag.on_touch_end.subscribe(on_touch_end);

        on_scroll = new Event();
        on_scroll_to = new Event();
        on_point_scroll = new Event();
    }

    override function init(druid:Druid<T>, context:T, ?druid_style:DruidStyle) {
        super.init(druid, context, druid_style);
        add_child(drag);
        update_size();
    }

    override function on_style_change(?style:ComponentStyle) {
        if (style == null)
            style = [];

        var set:(String, Dynamic) -> Void = Helper.null_default.bind(style, _, _);

        set("EXTRA_STRETCH_SIZE", 0);
        set("ANIM_SPEED", .2);
        set("BACK_SPEED", .35);
        set("FRICT", 0);
        set("FRICT_HOLD", 0);
        set("INERT_THRESHOLD", 3);
        set("INERT_SPEED", 30);
        set("POINTS_DEADZONE", 20);
        set("SMALL_CONTENT_SCROLL", false);

        is_inert = style["FRICT"] != 0 && style["FRICT_HOLD"] != 0 && style["INERT_SPEED"] != 0;

        this.style = style;
    }

    @:access(druid.base.Drag.is_drag)
    override function update(dt:Float) {
        if (drag.is_drag)
            update_hand_scroll();
        else
            update_free_scroll(dt);
    }

    /**
        Start scroll to target point

        @param point Target point
        @param is_instant Instant scroll flag
    **/
    public function scroll_to(point:Vector3, ?is_instant:Bool = false):Void {
        var b = available_pos;
        var target = Vmath.vector3(
            Helper.clamp(-point.x, b.x, b.z),
            Helper.clamp(-point.y, b.y, b.w),
            0
        );

        cancel_animate();
        is_animate = !is_instant;

        if (is_instant) {
            target_position = target;
            set_scroll_position(target);
        } else {
            Gui.animate(content_node, Gui.PROP_POSITION, target, GuiEasing.EASING_OUTSINE, style["ANIM_SPEED"], 0, (_, _) -> {
                is_animate = false;
                target_position = target;
                set_scroll_position(target);
            });
        }

        on_scroll_to.trigger([context, target, is_instant]);
    }

    /**
        Scroll to item in scroll by point index.

        @param index Point index
        @param skip_cb If true, skip the point callback
    **/
    public function scroll_to_index(index:Int, ?skip_cb:Bool = false):Void {
        if (points == null)
            return;

        index = Std.int(Helper.clamp(index, 1, points.length));

        if (selected != index) {
            selected = index;
            if (!skip_cb)
                on_point_scroll.trigger([context, index, points[index]]);
        }

        scroll_to(points[index]);
    }

    /**
        Start scroll to target scroll percent

        @param percent Target percent
        @param is_instant Instant scroll flag
    **/
    public function scroll_to_percent(percent:Vector3, is_instant:Bool):Void {
        var b = available_pos;
        var pos = Vmath.vector3(
            -Vmath.lerp(b.x, b.z, 1 - percent.x),
            -Vmath.lerp(b.w, b.y, 1 - percent.y),
            0
        );
        scroll_to(pos, is_instant);
    }

    /**
        Return current scroll progress status

        @eturn New vector with scroll progress values
    **/
    public function get_percent():Vector3 {
        var x_perc = 1 - inverse_lerp(available_pos.x, available_pos.z, position.x);
        var y_perc = inverse_lerp(available_pos.w, available_pos.y, position.y);
        return Vmath.vector3(x_perc, y_perc, 0);
    }

    /**
        Set scroll content size
        It will change content gui node size

        @param size The new size for content node
    **/
    public function set_size(size:Vector3):Void {
        Gui.set_size(content_node, size);
        update_size();
    }

    /**
        Set extra size for scroll stretching
        Set 0 to disable stretching effect

        @param stretch_size Size in pixels of additional scroll area
    **/
    public function set_extra_stretch_size(?stretch_size:Float = 0):Void {
        style["EXTRA_STRETCH_SIZE"] = stretch_size;
        update_size();
    }

    /**
        Set points of interest
        Scroll will always centered on closer points

        @param points Array of vector3 points
    **/
    public function set_points(points:Array<Vector3>):Void {
        points.sort((a, b) -> a.x > b.x ? 1 : (a.y < b.y ? 1 : -1));
        this.points = points;

        check_threshold();
    }

    private static function inverse_lerp(min:Float, max:Float, current:Float):Float
        return Helper.clamp((current - min) / (max - min), 0, 1);

    private static function get_border_vector(v:Vector4):Vector4 {
        if (v.x > v.z) {
            var t = v.x;
            v.x = v.z;
            v.z = t;
        }

        if (v.y > v.w) {
            var t = v.y;
            v.y = v.w;
            v.w = t;
        }

        return v;
    }

    private static function get_size_vector(v:Vector4):Vector3
        return Vmath.vector3(v.z - v.x, v.w - v.y, 0);

    private function on_scroll_drag(_:T, dx:Float, dy:Float):Void {
        var t = target_position;
        var b = available_pos;
        var eb = available_pos_extra;

        var x_perc = 1.0, y_perc = 1.0;

        if (t.x < b.x && dx < 0)
            x_perc = inverse_lerp(eb.x, b.x, t.x);
        if (t.x > b.z && dx > 0)
            x_perc = inverse_lerp(eb.z, b.z, t.x);
        if (!drag.can_x)
            x_perc = 0;

        if (t.y < b.y && dy < 0)
            y_perc = inverse_lerp(eb.y, b.y, t.y);
        if (t.y > b.w && dy > 0)
            y_perc = inverse_lerp(eb.w, b.w, t.y);
        if (!drag.can_y)
            y_perc = 0;

        t.x += dx * x_perc;
        t.y += dy * y_perc;
    }

    private function check_soft_zone():Void {
        var t = target_position;
        var b = available_pos;
        var speed:Float = style["BACK_SPEED"];

        if (t.x < b.x)
            t.x = Helper.step(t.x, b.x, Math.abs(t.x - b.x) * speed);
        if (t.x > b.z)
            t.x = Helper.step(t.x, b.z, Math.abs(t.x - b.z) * speed);
        if (t.y < b.y)
            t.y = Helper.step(t.y, b.y, Math.abs(t.y - b.y) * speed);
        if (t.y > b.w)
            t.y = Helper.step(t.y, b.w, Math.abs(t.y - b.w) * speed);
    }

    private function cancel_animate():Void {
        if (!is_animate) return;
        position = Gui.get_position(content_node);
        target_position = Vmath.vector3(position);
        Gui.cancel_animation(content_node, Gui.PROP_POSITION);
        is_animate = false;
    }

    private function set_scroll_position(pos:Vector3):Void {
        var be = available_pos_extra;
        pos.x = Helper.clamp(pos.x, be.x, be.z);
        pos.y = Helper.clamp(pos.y, be.w, be.y);

        if (position != pos) {
            position = Vmath.vector3(pos);
            Gui.set_position(content_node, position);
            on_scroll.trigger([context, position]);
        }
    }

    private function check_points():Void {
        if (points == null)
            return;

        var inert = inertion;
        if (!is_inert) {
            if (Math.abs(inert.x) > style["POINTS_DEADZONE"]) {
                scroll_to_index(selected - Helper.sign(inert.x));
                return;
            }
            if (Math.abs(inert.y) > style["POINTS_DEADZONE"]) {
                scroll_to_index(selected + Helper.sign(inert.y));
                return;
            }
        }

        var temp_dist = Math.POSITIVE_INFINITY;
        var temp_dist_on_inert = Math.POSITIVE_INFINITY;
        var index:Int = null;
        var index_on_inert:Int = null;
        var pos = position;

        for (i => p in points.keyValueIterator()) {
            var dist = Helper.distance(pos.x, pos.y, -p.x, -p.y);
            var on_inert = true;
            if (inert.x != 0 && Helper.sign(inert.x) != Helper.sign(-p.x - pos.x))
                on_inert = false;
            if (inert.y != 0 && Helper.sign(inert.y) != Helper.sign(-p.y - pos.y))
                on_inert = false;

            if (dist < temp_dist) {
                index = i;
                temp_dist = dist;
            }
            if (on_inert && dist < temp_dist_on_inert) {
                index_on_inert = i;
                temp_dist_on_inert = dist;
            }
        }

        scroll_to_index(index_on_inert != null ? index_on_inert : index);
    }

    private function check_threshold():Void {
        var is_stopped = false;
        var i = inertion;

        if (i.x != 0 && Math.abs(i.x) < style["INERT_THRESHOLD"]) {
            is_stopped = true;
            i.x = 0;
        }
        if (i.y != 0 && Math.abs(i.y) < style["INERT_THRESHOLD"]) {
            is_stopped = true;
            i.y = 0;
        }

        if (is_stopped || !is_inert)
            check_points();
    }

    private function update_free_scroll(dt:Float):Void {
        var p = position;
        var t = target_position;
        var i = inertion;

        if (is_inert && (i.x != 0 || i.y != 0)) {
            t.x = p.x + i.x * style["INERT_SPEED"] * dt;
            t.y = p.y + i.y * style["INERT_SPEED"] * dt;

            check_threshold();
        }

        i *= style["FRICT"];

        check_soft_zone();
        if (p != t)
            set_scroll_position(t);
    }

    private function update_hand_scroll():Void {
        var dx = target_position.x - position.x;
        var dy = target_position.y - position.y;

        inertion.x = (inertion.x + dx) * style["FRICT_HOLD"];
        inertion.y = (inertion.y + dy) * style["FRICT_HOLD"];

        set_scroll_position(target_position);
    }

    private function on_touch_start(_:T):Void {
        inertion.x = inertion.y = 0;
        target_position = Vmath.vector3(position);
    }

    private function on_touch_end(_:T):Void
        check_threshold();

    private function update_size():Void {
        var view_border = Helper.get_border(view_node);
        var view_size = Vmath.mul_per_elem(Gui.get_size(view_node), Gui.get_scale(view_node));

        var content_border = Helper.get_border(content_node);
        var content_size = Vmath.mul_per_elem(Gui.get_size(content_node), Gui.get_scale(content_node));

        available_pos = get_border_vector(view_border - content_border);
        available_size = get_size_vector(available_pos);

        drag.can_x = available_size.x > 0;
        drag.can_y = available_size.y > 0;

        var content_border_extra = Helper.get_border(content_node);
        var stretch_size = style["EXTRA_STRETCH_SIZE"];

        if (drag.can_x) {
            var sign = content_size.x > view_size.x ? 1 : -1;
            content_border_extra.x -= stretch_size * sign;
            content_border_extra.z += stretch_size * sign;
        }

        if (drag.can_y) {
            var sign = content_size.y > view_size.y ? 1 : -1;
            content_border_extra.y += stretch_size * sign;
            content_border_extra.w -= stretch_size * sign;
        }

        if (!style["SMALL_CONTENT_SCROLL"]) {
            drag.can_x = content_size.x > view_size.x;
            drag.can_y = content_size.y > view_size.y;
        }

        available_pos_extra = get_border_vector(view_border - content_border_extra);
        available_size_extra = get_size_vector(available_pos_extra);
    }
}