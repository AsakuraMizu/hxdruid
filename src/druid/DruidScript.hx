package druid;

import defold.types.Hash;
import defold.types.Message;
import defold.types.Url;
import defold.support.GuiScript;
import defold.support.ScriptOnInputAction;

class DruidScript<T:{}> extends GuiScript<T> {
    private var druid:Druid<T>;

    override function init(self:T) {
        super.init(self);
        druid = Manager.create(self);
    }

    override function final_(self:T) {
        druid.final_();
    }

    override function on_input(self:T, action_id:Hash, action:ScriptOnInputAction):Bool {
        return druid.on_input(action_id, action);
    }

    override function on_message<TMessage>(self:T, message_id:Message<TMessage>, message:TMessage, sender:Url) {
        druid.on_message(message_id, message,sender);
    }

    override function update(self:T, dt:Float) {
        druid.update(dt);
    }
}