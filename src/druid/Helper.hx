package druid;

import defold.Gui;
import defold.Msg;
import defold.Vmath;
import defold.types.*;

/**
    Druid helper module for gui layouts
**/
class Helper {
    private static function get_text_width(text_node:GuiNode):Float {
        if (text_node == null) return 0;
        return Gui.get_text_metrics_from_node(text_node).width * Gui.get_scale(text_node).x;
    }

    private static function get_icon_width(icon_node:GuiNode):Float {
        if (icon_node == null) return 0;
        return Gui.get_size(icon_node).x * Gui.get_scale(icon_node).x;
    }

    /**
        Center two nodes

        Nodes will be center around 0 x position
        text_node will be first (at left side)

        @param text_node Text node
        @param icon_node Box node
        @param margin Offset between nodes
    **/
    public static function centrate_text_with_icon(text_node:GuiNode, icon_node:GuiNode, ?margin:Float = 0):Void {
        var text_width = get_text_width(text_node);
        var icon_width = get_icon_width(icon_node);
        var width = text_width + icon_width;

        if (text_node != null) {
            var pos = Gui.get_position(text_node);
            pos.x = -width / 2 + text_width - margin / 2;
            Gui.set_position(text_node, pos);
        }

        if (icon_node != null) {
            var pos = Gui.get_position(icon_node);
            pos.x = width / 2 - icon_width + margin / 2;
            Gui.set_position(icon_node, pos);
        }
    }

    /**
        Center two nodes

        Nodes will be center around 0 x position
        icon_node will be first (at left side)

        @param icon_node Box node
        @param text_node Text node
        @param margin Offset between nodes
    **/
    public static function centrate_icon_with_text(icon_node:GuiNode, text_node:GuiNode, ?margin:Float = 0):Void {
        var icon_width = get_icon_width(icon_node);
        var text_width = get_text_width(text_node);
        var width = text_width + icon_width;

        if (text_node != null) {
            var pos = Gui.get_position(text_node);
            pos.x = width / 2 - text_width + margin / 2;
            Gui.set_position(text_node, pos);
        }

        if (icon_node != null) {
            var pos = Gui.get_position(icon_node);
            pos.x = -width / 2 + icon_width - margin / 2;
            Gui.set_position(icon_node, pos);
        }
    }

    public static function step(current:Float, target:Float, step:Float):Float {
        if (current < target) {
            return Math.min(current+ step, target);
        } else {
            return Math.max(target, current - step);
        }
    }

    public static function clamp(a:Float, min:Float, max:Float):Float {
        if (min > max) {
            var tmp = min;
            min = max;
            max = tmp;
        }

        if (a >= min && a <= max)
            return a;
        else if (a < min)
            return min;
        else
            return max;
    }

    public static function distance(x1:Float, y1:Float, x2:Float, y2: Float):Float {
        return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
    }

    public static function sign(val:Float):Int {
        if (val == 0)
            return 0;
        return val < 0 ? -1 : 1;
    }

    public static function round(num:Float, ?numDecimalPlaces:Int = 0):Float {
        var mult = Math.pow(10, numDecimalPlaces);
        return Math.floor(num * mult + 0.5) / mult;
    }

    public static function lerp(a:Float, b:Float, t:Float):Float {
        return a + (b - a) * t;
    }

    /**
        Check if node is enabled in gui hierarchy

        Return false, if node or any his parent is disabled.

        @param node Gui node
        @return Is enabled in hierarchy
    **/
    public static function is_enabled(node:GuiNode):Bool {
        var is_enabled = Gui.is_enabled(node);
        var parent = Gui.get_parent(node);
        while (parent != null && is_enabled) {
            is_enabled = is_enabled && Gui.is_enabled(parent);
            parent = Gui.get_parent(parent);
        }

        return is_enabled;
    }

    /**
        Get node offset for given gui pivot

        @param pivot node pivot
        @return Vector offset with [-1..1] values
    **/
    public static function get_pivot_offset(pivot:GuiPivot):Vector3 {
        return Const.PIVOTS[pivot];
    }

    /**
        Check if device is mobile (Android or iOS)
    **/
    public static function is_mobile():Bool {
        var system_name = defold.Sys.get_sys_info().system_name;
        return system_name == Const.OS.IOS || system_name == Const.OS.ANDROID;
    }

    /**
        Check if device is HTML5
    **/
    public static function is_web():Bool {
        var system_name = defold.Sys.get_sys_info().system_name;
        return system_name == Const.OS.BROWSER;
    }

    /**
        Distance from node to size border
    **/
    public static function get_border(node:GuiNode):Vector4 {
        var pivot = Gui.get_pivot(node);
        var pivot_offset = get_pivot_offset(pivot);
        var size = Vmath.mul_per_elem(Gui.get_size(node), Gui.get_scale(node));
        return Vmath.vector4(
            -size.x * (0.5 + pivot_offset.x),
            size.y * (0.5 - pivot_offset.y),
            size.x * (0.5 - pivot_offset.x),
            -size.y * (0.5 + pivot_offset.y)
        );
    }
}

/**
    Druid module with utils on string formats
**/
class Formats {
    /**
        Return number with zero number prefix

        @param num Number for conversion
        @param count Count of numerals
        @return String with need count of zero
    **/
    public static function add_prefix_zeros(num:Int, count:Int):String {
        var res = Std.string(num);
        for (i in res.length...count)
            res = "0" + res;
        return res;
    }

    /**
        Convert seconds to string minutes:seconds

        @param sec Seconds
        @return minutes:seconds
    **/
    public static function second_string_min(sec:Int):String {
        var mins = Math.floor(sec / 60);
        var seconds = Math.floor(sec - mins * 60);
        return add_prefix_zeros(mins, 2) + ":" + add_prefix_zeros(seconds, 2);
    }
}

/**
    Druid inner module to acquire/release input
**/
class Input {
    private static final ADD_FOCUS = new Message("acquire_input_focus");
    private static final REMOVE_FOCUS = new Message("release_input_focus");
    private static final PATH_OBJ = ".";

    public inline static function focus():Void Msg.post(PATH_OBJ, ADD_FOCUS);
    public inline static function remove():Void Msg.post(PATH_OBJ, REMOVE_FOCUS);

}