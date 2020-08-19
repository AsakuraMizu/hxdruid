package druid.styles;

import defold.Gui;
import defold.Vmath;
import defold.types.Vector3;
import druid.base.Button;
import druid.base.Checkbox;
import druid.base.Input;
import druid.types.DruidStyle;

private class ButtonStyle {
    private static final HOVER_SCALE = Vmath.vector3(.02, .02, 1);
    private static final HOVER_MOUSE_SCALE = Vmath.vector3(.01, .01, 1);
    private static final HOVER_TIME = .04;
    private static final SCALE_CHANGE = Vmath.vector3(.035, .035, 1);
    private static final BTN_SOUND = "click";
    private static final BTN_SOUND_DISABLED = "click";
    private static final DISABLED_COLOR = Vmath.vector4(0, 0, 0, 1);
    private static final ENABLED_COLOR = Vmath.vector4(1);

    public static function scale_to<T:{}>(button:Button<T>, node:GuiNode, to:Vector3, ?callback:(T, GuiNode) -> Void, ?time = .1, ?delay = 0, ?easing:GuiEasing = EASING_INSINE):Void
        Gui.animate(node, Gui.PROP_SCALE, to, easing, time, delay, callback);

    public static function tap_scale_animation<T:{}>(button:Button<T>, node:GuiNode, target_scale:Vector3):Void
        scale_to(button, node, target_scale, (_, _) -> scale_to(button, node, button.start_scale));

    public static function hover_scale<T:{}>(button:Button<T>, node:GuiNode, target_scale:Vector3, time:Float):Void
        Gui.animate(node, Gui.PROP_SCALE, target_scale, EASING_OUTSINE, time);

    public static function on_hover<T:{}>(button:Button<T>, node:GuiNode, state:Bool):Void {
        var scale_to = button.start_scale + HOVER_SCALE;
        var target_scale = state ? scale_to : button.start_scale;
        hover_scale(button, node, target_scale, HOVER_TIME);
    }

    public static function on_mouse_hover<T:{}>(button:Button<T>, node:GuiNode, state:Bool):Void {
        var scale_to = button.start_scale + HOVER_MOUSE_SCALE;
        var target_scale = state ? scale_to : button.start_scale;
        hover_scale(button, node, target_scale, HOVER_TIME);
    }

    public static function on_click<T:{}>(button:Button<T>, node:GuiNode):Void {
        var scale_to = button.start_scale + SCALE_CHANGE;
        tap_scale_animation(button, node, scale_to);
        Druid.play_sound(BTN_SOUND);
    }

    public static function on_click_disabled<T:{}>(button:Button<T>, node:GuiNode):Void
        Druid.play_sound(BTN_SOUND_DISABLED);

    public static function on_set_enabled<T:{}>(button:Button<T>, node:GuiNode, state:Bool):Void {
        if (state)
            Gui.set_color(node, ENABLED_COLOR);
        else
            Gui.set_color(node, DISABLED_COLOR);
    }
}

private class CheckboxStyle {
    public static function on_chnage_state<T:{}>(checkbox:Checkbox<T>, node:GuiNode, state:Bool):Void {
        var target = state ? 1 : 0;
        Gui.animate(node, "color.w", target, EASING_OUTSINE, .1);
    }
}

@:access(druid.base.Input.button)
private class InputStyle {
    private static final BUTTON_SELECT_INCREASE = 1.1;

    public static function on_select<T:{}>(input:Input<T>, button:Button<T>):Void {
        var target_scale = button.start_scale * BUTTON_SELECT_INCREASE;
        Gui.animate(button.anim_node, Gui.PROP_SCALE, target_scale, EASING_OUTSINE, .15);
    }

    public static function on_unselect<T:{}>(input:Input<T>, button:Button<T>):Void {
        var start_scale = button.start_scale;
        Gui.animate(button.anim_node, Gui.PROP_SCALE, start_scale, EASING_OUTSINE, .15);
    }

    public static function on_input_wrong<T:{}>(input:Input<T>, button:Button<T>):Void {
        var start_pos = button.start_pos;
        Gui.animate(button.anim_node, "position.x", start_pos.x - 3, EASING_OUTSINE, .05, 0, (_, _) -> {
            Gui.animate(button.anim_node, "position.x", start_pos.x + 3, EASING_OUTSINE, .1, 0, (_, _) -> {
                Gui.animate(button.anim_node, "position.x", start_pos.x, EASING_OUTSINE, .05);
            });
        });
    }
}

class Default {
    public static final style:DruidStyle = [
        "Button" => [
            "LONGTAP_TIME" => .4,
            "AUTOHOLD_TRIGGER" => .8,
            "DOUBLETAP_TIME" => .4,
            "on_hover" => ButtonStyle.on_hover,
            "on_mouse_hover" => ButtonStyle.on_mouse_hover,
            "on_click" => ButtonStyle.on_click,
            "on_click_disabled" => ButtonStyle.on_click_disabled,
            "on_set_enabled" => ButtonStyle.on_set_enabled,
        ],
        "Drag" => [
            "DRAG_DEADZONE" => 10,
        ],
        "Scroll" => [
            "ANIM_SPEED" => 0.2,
            "BACK_SPEED" => 0.35,
            "FRICT" => 0.93,
            "FRICT_HOLD" => 0.79,
            "INERT_THRESHOLD" => 2.5,
            "INERT_SPEED" => 30,
            "EXTRA_STRETCH_SIZE" => 100,
            "POINTS_DEADZONE" => 20,
            "SCROLL_WHEEL_SPEED" => 20,
            "SMALL_CONTENT_SCROLL" => true,
        ],
        "Progress" => [
            "SPEED" => 5,
            "MIN_DELTA" => .005,
        ],
        "Checkbox" => [
            "on_change_state" => CheckboxStyle.on_chnage_state,
        ],
        "Swipe" => [
            "SWIPE_THRESHOLD" => 50,
            "SWIPE_TIME" => .4,
            "SWIPE_TRIGGER_ON_MOVE" => true,
        ],
        "Input" => [
            "IS_LONGTAP_ERASE" => true,
            "MASK_DEFAULT_CHAR" => "*",
            "on_select" => InputStyle.on_select,
            "on_unselect" => InputStyle.on_unselect,
            "on_input_wrong" => InputStyle.on_input_wrong,
            "Button" => [
                "LONGTAP_TIME" => .4,
                "AUTOHOLD_TRIGGER" => .8,
                "DOUBLETAP_TIME" => .4,
            ],
        ],
    ];
}
