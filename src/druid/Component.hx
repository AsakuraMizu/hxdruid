package druid;

import defold.Gui;
import defold.types.Hash;
import defold.types.Message;
import defold.types.Url;
import defold.support.ScriptOnInputAction;
import druid.types.*;

/**
    Basic class for all Druid components
**/
class Component<T:{}> {
    /**
        Component name
    **/
    public var name(default, null):String = "";

    /**
        List of component's interest
    **/
    public var interest(default, null):Array<Interest> = [];

    /**
        The parent druid instance
    **/
    public var druid(default, null):Druid<T>;

    /**
        Druid context. Usually it is self of script
    **/
    public var context(default, null):T;

    /**
        Component template name
    **/
    public var template:String;

    /**
        Component nodes list
    **/
    public var nodes:Map<String, GuiNode>;

    /**
        Input priority in current input stack
    **/
    public var increased_input_priority:Bool = false;

    /**
        Parent component
    **/
    private var parent:Component<T>;

    /**
        Druid style
    **/
    private var style:ComponentStyle;

    /**
        Initialize a component

        @param druid The parent druid instance
        @param context Druid context. Usually it is self of script
        @param druid_style Druid style
    **/
    public function init(druid:Druid<T>, context:T, ?druid_style:DruidStyle) {
        this.druid = druid;
        this.context = context;
        set_style(druid_style);
    }

    /**
        Set current component style

        Invoke `on_style_change` on component, if exist. Component should handle
        their style changing and store all style params

        @param druid_style druid style
    **/
    public function set_style(?druid_style: DruidStyle):Void {
        if (druid_style == null)
            druid_style = new DruidStyle();
        style = druid_style[name];

        on_style_change(style);
    }

    /**
        Get node for component by name.

        It auto pick node by template name or from nodes by clone_tree
        if they was setup via component:set_nodes, component:set_template
    **/
    public function get_node(node_or_name:NodeOrString):GuiNode {
        if (!Std.isOfType(node_or_name, String))
            return node_or_name;

        var template_name = "";
        if (template != null)
            template = template + "/";

        if (nodes != null)
            return nodes[template_name + node_or_name];
        else
            return Gui.get_node(template_name + node_or_name);
        return node_or_name;
    }

    /**
        Add child component

        @param component Component
    **/
    public function add_child(component:Component<T>):Component<T> {
        component.parent = this;
        return druid.add(component);
    }

    /**
        Return true, if current component is child of another component

        @return True, if current component is child of another
    **/
    public function is_child_of(other:Component<T>):Bool
        return parent == other;

    /**
        Call only if exist interest: Const.ON_UPDATE
    **/
    public function update(dt:Float):Void {}

    /**
        Call only if exist interest: Const.ON_INPUT or Const.ON_INPUT_HIGH
    **/
    public function on_input(action_id:Hash, action:ScriptOnInputAction):Bool return false;

    /**
        Call on component creation and on component.set_style() function
    **/
    public function on_style_change(style:ComponentStyle):Void {}

    /**
        Call only if exist interest: const.ON_MESSAGE
    **/
    public function on_message<TMessage>(message_id:Message<TMessage>, message:TMessage, sender:Url):Void {}

    /**
        Call only if component with ON_LANGUAGE_CHANGE interest
    **/
    public function on_language_change():Void {}

    /**
        Call only if component with ON_LAYOUT_CHANGE interest
    **/
    public function on_layout_change():Void {}

    /**
        Call, if input was capturing before this component

        Example: scroll is start scrolling, so you need unhover button
    **/
    public function on_input_interrupt():Void {}

    /**
        Call, if game lost focus. Need ON_FOCUS_LOST intereset
    **/
    public function on_focus_lost():Void {}

    /**
        Call, if game gained focus. Need ON_FOCUS_GAINED intereset
    **/
    public function on_focus_gained():Void {}

    /**
        Call on component remove or on druid.final
    **/
    public function on_remove():Void {}

    private function invoke_style(name: String, args:Array<Dynamic>):Void {
        args = ([this]:Array<Dynamic>).concat(args);
        if (Reflect.isFunction(style[name]))
            Reflect.callMethod(null, style[name], args);
    }
}