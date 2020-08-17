package druid.base;

import defold.Vmath;
import defold.Gui;
import defold.types.Hash;
import defold.types.Vector3;
import defold.types.Vector4;
import druid.types.NodeOrString;

/**
    Component to handle all GUI texts.
**/
class Text<T:{}> extends Component<T> {
    private var node:GuiNode;
    private var pos:Vector3;
    private var start_scale:Vector3;
    private var scale:Vector3;
    private var last_scale:Vector3;
    private var start_size:Vector3;
    private var text_area:Vector3;
    private var is_no_adjust:Bool;
    private var color:Vector4;
    private var space_width:Map<Hash, Float> = [];

    private var last_value:String;

    /**
        On set text callback
    **/
    public var on_set_text(default, null):Event<(T, String) -> Void>;

    /**
        On adjust text size callback
    **/
    public var on_update_text_scale(default, null):Event<(T, Vector3) -> Void>;

    /**
        On change pivot callback
    **/
    public var on_set_pivot(default, null):Event<(T, GuiPivot) -> Void>;

    /**
        Component constructor

        @param node Gui text node
        @param value Initial text. Default value is node text from GUI scene.
        @param no_adjust If true, text will be not auto-adjust size
    **/
    public function new(node:NodeOrString, ?value:String, ?no_adjust:Bool = false) {
        name = "Text";

        this.node = get_node(node);
        pos = Gui.get_position(this.node);
        scale = start_scale = Gui.get_scale(this.node);
        text_area = start_size = Gui.get_size(this.node);
        text_area.x *= start_scale.x;
        text_area.y *= start_scale.y;
        is_no_adjust = no_adjust;
        color = Gui.get_color(this.node);
        
        on_set_text = new Event();
        on_update_text_scale = new Event();
        on_set_pivot = new Event();

        set_to(value == null ? Gui.get_text(this.node) : value);
    }

    /**
        Calculate text width with font with respect to trailing space
    **/
    public function get_text_width(?text:String):Float {
        if (text == null)
            text = last_value;

        var font = Gui.get_font(node);
        var scale = Gui.get_scale(node);
        var result = Gui.get_text_metrics(font, text, 0, false, 0, 0).width;

        var arr = text.split("");
        arr.reverse();
        for (i in arr) {
            if (i != " ")
                break;
            result += get_space_width(font);
        }
        return result * scale.x;
    }

    /**
        Set text to text field

        @param set_to Text for node
    **/
    public function set_to(set_to:String):Void {
        last_value = set_to;
        Gui.set_text(node, set_to);

        on_set_text.trigger([context, set_to]);

        if (!is_no_adjust)
            update_text_area_size();
    }

    /**
        Set color

        @param color Color for node
    **/
    public function set_color(color:Vector4):Void {
        this.color = color;
        Gui.set_color(node, color);
    }

    /**
        Set alpha

        @param alpha Alpha for node
    **/
    public function set_alpha(alpha:Float):Void {
        color.w = alpha;
        Gui.set_color(node, color);
    }

    /**
        Set scale

        @param scale Scale for node
    **/
    public function set_scale(scale:Vector3):Void {
        last_scale = scale;
        Gui.set_scale(node, scale);
    }

    /**
        Set text pivot. Text will re-anchor inside his text area

        @param pivot Gui pivot constant
    **/
    public function set_pivot(pivot:GuiPivot):Void {
        var prev_pivot = Gui.get_pivot(node);
        var prev_offset = Const.PIVOTS[prev_pivot];

        Gui.set_pivot(node, pivot);
        var cur_offset = Const.PIVOTS[pivot];

        var pos_offset = Vmath.vector3(
            text_area.x * (cur_offset.x - prev_offset.x),
            text_area.y * (cur_offset.y - prev_offset.y),
            0
        );

        pos += pos_offset;
        Gui.set_position(node, pos);

        on_set_pivot.trigger([context, pivot]);
    }

    /**
        Return true, if text with line break

        @return Is text node with line break
    **/
    public function is_multiline():Bool
        return Gui.get_line_break(node);

    private function update_text_size():Void {
        var size = Vmath.vector3(
            start_size.x * (start_scale.x / scale.x),
            start_size.y * (start_scale.y / scale.y),
            start_size.z
        );
        Gui.set_size(node, size);
    }

    private function update_text_area_size():Void {
        Gui.set_scale(node, start_scale);
        Gui.set_size(node, start_size);

        var max_width = text_area.x;
        var metrics = Gui.get_text_metrics_from_node(node);

        var scale_modifier = max_width / metrics.width;
        scale_modifier = Math.min(scale_modifier, start_scale.x);

        var max_height = text_area.y;
        scale_modifier = Math.min(scale_modifier, max_height / metrics.height);

        var cur_scale = Gui.get_scale(node);
        var new_scale = Vmath.vector3(scale_modifier, scale_modifier, cur_scale.z);
        Gui.set_scale(node, new_scale);
        scale = new_scale;

        update_text_size();

        on_update_text_scale.trigger([context, new_scale]);
    }

    private function get_space_width(font:Hash):Float {
        if (space_width[font] == null) {
            var no_space = Gui.get_text_metrics(font, "1", 0, false, 0, 0).width;
            var with_space = Gui.get_text_metrics(font, " 1", 0, false, 0, 0).width;
            space_width[font] = with_space - no_space;
        }

        return space_width[font];
    }
}