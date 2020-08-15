package druid;

import defold.Msg;
import defold.Window;
import druid.types.*;

class Manager {
    /**
        Druid default style
    **/
    public static var default_style:DruidStyle;

    /**
        Druid text function

        Druid locale component will call this function to get translated text
    **/
    public static var get_text:String -> String = name -> "[Druid]: locales not inited";

    /**
        Druid sound function

        Component will call this function to play sound by sound_id
    **/
    public static var play_sound:String -> Void = name -> {};

    private static final instances:Array<Druid<Dynamic>> = [];

    private static function get_druid_instances():Array<Druid<Dynamic>> {
        for (i in instances) {
            if (i.deleted) instances.remove(i);
        }
        return instances;
    }

    /**
        Create Druid instance

        @param context Druid context. Usually it is self of script
        @param style Druid style module
        @return Druid instance
    **/
    public static function create<T:{}>(context:T, ?style:DruidStyle):Druid<T> {
        var instance = new Druid(context, style);
        instances.push(instance);
        return instance;
    }

    /**
        Callback on global window event

        Used to trigger on_focus_lost and on_focus_gain
    **/
    public static function on_window_callback(event:WindowEvent, data:WindowEventData):Void {
        var instances = get_druid_instances();

        if (event == WINDOW_EVENT_FOCUS_LOST) {
            for (i in instances)
                Msg.post(i.url, Const.FOCUS_LOST.msg);
        } else if (event == WINDOW_EVENT_FOCUS_GAINED) {
            for (i in instances)
                Msg.post(i.url, Const.FOCUS_GAINED.msg);
        }
    }

    /**
        Callback on global layout change event
    **/
    public static function on_layout_change():Void {
        var instances = get_druid_instances();

        for (i in instances)
            Msg.post(i.url, Const.LAYOUT_CHANGE.msg);
    }

    /**
        Callback on global language change event
    **/
    public static function on_language_change():Void {
        var instances = get_druid_instances();

        for (i in instances)
            Msg.post(i.url, Const.LANGUAGE_CHANGE.msg);
    }
}