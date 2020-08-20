package druid;

import Defold.hash;
import defold.Gui;
import defold.Vmath;
import defold.types.*;
import druid.types.*;

enum abstract SIDE(String) {
    var X;
    var Y;
}

enum abstract SWIPE(String) {
    var UP;
    var DOWN;
    var LEFT;
    var RIGHT;
}

/**
    Druid constants
**/
class Const {
    public static var ACTION_TEXT(default, never) = hash("text");
    public static var ACTION_MARKED_TEXT(default, never) = hash("marked_text");

    public static var ACTION_BACKSPACE(default, never) = hash("key_backspace");
    public static var ACTION_ENTER(default, never) = hash("key_enter");
    public static var ACTION_BACK(default, never) = hash("key_back");
    public static var ACTION_ESC(default, never) = hash("key_esc");
    public static var ACTION_TOUCH(default, never) = hash("touch");
    public static var ACTION_SCROLL_UP(default, never) = hash("scroll_up");
    public static var ACTION_MULTITOUCH(default, never) = hash("multitouch");
    public static var ACTION_SCROLL_DOWN(default, never) = hash("scroll_down");

    /**
        Component Interests
    **/
    public static var ON_INPUT(default, never) = new Interest("on_input");
    public static var ON_UPDATE(default, never) = new Interest("on_update");
    public static var ON_MESSAGE(default, never) = new Interest("on_message");
    public static var ON_INPUT_HIGH(default, never) = new Interest("on_input_high");
    public static var ON_FOCUS_LOST(default, never) = new Interest("on_focus_lost");
    public static var ON_FOCUS_GAINED(default, never) = new Interest("on_focus_gained");
    public static var ON_LAYOUT_CHANGE(default, never) = new Interest("on_layout_change");
    public static var ON_LANGUAGE_CHANGE(default, never) = new Interest("on_language_change");
    public static var ALL_INTERESTS(default, never) = [
        ON_INPUT,
        ON_UPDATE,
        ON_MESSAGE,
        ON_FOCUS_LOST,
        ON_INPUT_HIGH,
        ON_FOCUS_GAINED,
        ON_LAYOUT_CHANGE,
        ON_LANGUAGE_CHANGE,
    ];

    public static var PIVOTS(default, never) = [
        PIVOT_CENTER => Vmath.vector3(0),
        PIVOT_N => Vmath.vector3(0, 0.5, 0),
        PIVOT_NE => Vmath.vector3(0.5, 0.5, 0),
        PIVOT_E => Vmath.vector3(0.5, 0, 0),
        PIVOT_SE => Vmath.vector3(0.5, -0.5, 0),
        PIVOT_S => Vmath.vector3(0, -0.5, 0),
        PIVOT_SW => Vmath.vector3(-0.5, -0.5, 0),
        PIVOT_W => Vmath.vector3(-0.5, 0, 0),
        PIVOT_NW => Vmath.vector3(-0.5, 0.5, 0),
    ];

    public static var UI_INPUT(default, never) = [
        ON_INPUT_HIGH,
        ON_INPUT
    ];

    public static var OS(default, never) = {
        ANDROID: "Android",
        IOS: "iPhone OS",
        MAC: "Darwin",
        LINUX: "Linux",
        WINDOWS: "Windows",
        BROWSER: "HTML5",
    };
}

class SpecificUIMessages {
    public static var FOCUS_LOST(default, never) = new Message<Void>("on_focus_lost");
    public static var FOCUS_GAINED(default, never) = new Message<Void>("on_focus_gained");
    public static var LAYOUT_CHANGE(default, never) = new Message<Void>("on_layout_change");
    public static var LANGUAGE_CHANGE(default, never) = new Message<Void>("on_language_change");
}