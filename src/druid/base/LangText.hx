package druid.base;

import druid.types.DruidStyle;
import druid.types.NodeOrString;

/**
    Component to handle all GUI texts
    Good working with localization system
**/
class LangText<T:{}> extends Component<T> {
    private var text:Text<T>;
    private var last_locale_id:String;
    private var last_locale_args:Array<String> = [];

    /**
        On change text callback
    **/
    public var on_change(default, null):Event<T -> Void>;

    /**
        Component constructor

        @param node The text node
        @param locale_id Default locale id
        @param no_adjust If true, will not correct text size
    **/
    public function new(node:NodeOrString, ?locale_id:String, ?locale_args:Array<String>, ?no_adjust:Bool = false) {
        name = "LangText";
        interest = [Const.ON_LANGUAGE_CHANGE];

        text = new Text(node, locale_id, no_adjust);
        last_locale_id = locale_id;
        last_locale_args = locale_args;

        on_change = new Event();
    }

    override function init(druid:Druid<T>, context:T, ?druid_style:DruidStyle) {
        super.init(druid, context, druid_style);

        add_child(text);
        on_language_change();
    }

    override function on_language_change()
        if (last_locale_id != null)
            translate(last_locale_id, last_locale_args);

    /**
        Setup raw text to lang_text component

        @param text Text for text node
    **/
    public function set_to(text:String):Void {
        last_locale_id = null;
        this.text.set_to(text);
        on_change.trigger([context]);
    }

    /**
        Translate the text by locale_id

        @param locale_id Locale id
    **/
    public function translate(?locale_id:String, ?locale_args:Array<String>):Void {
        if (locale_id != null)
            last_locale_id = locale_id;
        if (locale_args != null)
            last_locale_args = locale_args;

        text.set_to(Druid.get_text(last_locale_id, last_locale_args));
    }
}