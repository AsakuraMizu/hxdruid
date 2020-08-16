package druid;

import Defold.hash;
import defold.Gui;
import defold.Vmath;
import defold.types.*;
import druid.types.*;

/**
    Druid constants
**/
class Const {
    public static final ACTION_TEXT = hash("text");
    public static final ACTION_MARKED_TEXT = hash("marked_text");

    public static final ACTION_BACKSPACE = hash("key_backspace");
    public static final ACTION_ENTER = hash("key_enter");
    public static final ACTION_BACK = hash("key_back");
    public static final ACTION_ESC = hash("key_esc");
    public static final ACTION_TOUCH = hash("touch");
    public static final ACTION_SCROLL_UP = hash("scroll_up");
    public static final ACTION_MULTITOUCH = hash("multitouch");
    public static final ACTION_SCROLL_DOWN = hash("scroll_down");

    /**
        Component Interests
    **/
    public static final ON_INPUT = new Interest("on_input");
    public static final ON_UPDATE = new Interest("on_update");
    public static final ON_MESSAGE = new Interest("on_message");
    public static final ON_INPUT_HIGH = new Interest("on_input_high");
    public static final ON_FOCUS_LOST = new Interest("on_focus_lost");
    public static final ON_FOCUS_GAINED = new Interest("on_focus_gained");
    public static final ON_LAYOUT_CHANGE = new Interest("on_layout_change");
    public static final ON_LANGUAGE_CHANGE = new Interest("on_language_change");
    public static final ALL_INTERESTS = [
        ON_INPUT,
        ON_UPDATE,
        ON_MESSAGE,
        ON_FOCUS_LOST,
        ON_INPUT_HIGH,
        ON_FOCUS_GAINED,
        ON_LAYOUT_CHANGE,
        ON_LANGUAGE_CHANGE,
    ];

    public static final PIVOTS = [
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

    public static final FOCUS_LOST = {msg: new Message<Void>("on_focus_lost")};
    public static final FOCUS_GAINED = {msg:new Message<Void>("on_focus_gained")};
    public static final LAYOUT_CHANGE = {msg:new Message<Void>("on_layout_change")};
    public static final LANGUAGE_CHANGE = {msg:new Message<Void>("on_language_change")};

    public static final SPECIFIC_UI_MESSAGES = [
        FOCUS_LOST => { interest: ON_FOCUS_LOST, name: "on_focus_lost" },
        FOCUS_GAINED => { interest: ON_FOCUS_GAINED, name: "on_focus_gained" },
        LAYOUT_CHANGE => { interest: ON_LAYOUT_CHANGE, name: "on_layout_change" },
        LANGUAGE_CHANGE => { interest: ON_LANGUAGE_CHANGE, name: "on_language_change" },
    ];

    public static final UI_INPUT = [
        ON_INPUT_HIGH,
        ON_INPUT
    ];

    public static final OS = {
        ANDROID: "Android",
        IOS: "iPhone OS",
        MAC: "Darwin",
        LINUX: "Linux",
        WINDOWS: "Windows",
        BROWSER: "HTML5",
    };

    public static final SIDE = {
        X: "x",
        Y: "y",
    }

    public static final SWIPE = {
        UP: "up",
        DOWN: "down",
        LEFT: "left",
        RIGHT: "right",
    }
}