package druid.support;

import defold.types.Hash;
import defold.types.Message;
import defold.types.Url;
import defold.support.GuiScript;
import defold.support.ScriptOnInputAction;
import druid.types.DruidStyle;

class DruidScript<T:{}> extends GuiScript<T> {
    private var druid_instance:Druid<T>;

    /**
        Add component

        @param component Component
    **/
    private function add(component:Component<T>):Void
        druid_instance.add(component);

    /**
        Set druid style

        Invoke `set_style` on every component.

        @param druid_style druid style
    **/
    private function set_style(?style: DruidStyle):Void
        druid_instance.set_style(style);

    /**
        Remove component from druid instance

        Component `on_remove` function will be invoked, if exist.

        @param component Component instance
    **/
    public function remove(component: Component<T>):Void
        druid_instance.remove(component);

    override function init(self:T):Void
        druid_instance = Manager.create(self);

    override function final_(self:T):Void
        druid_instance.final_();

    override function on_input(self:T, action_id:Hash, action:ScriptOnInputAction):Bool
        return druid_instance.on_input(action_id, action);

    override function on_message<TMessage>(self:T, message_id:Message<TMessage>, message:TMessage, sender:Url):Void
        druid_instance.on_message(message_id, message,sender);

    override function update(self:T, dt:Float):Void
        druid_instance.update(dt);
}