package druid;

import haxe.Constraints.Function;

/**
    Druid event
**/
class Event<T:Function> {
    /**
        Event constructur

        @param initial_callback subscribe the callback on new event, if callback exist
    **/
    public function new(?initial_callback:T) {
        clear();
        if (initial_callback != null)
            subscribe(initial_callback);
    }

    /**
        Subscribe callback on event

        @param callback callback itself
    **/
    public function subscribe(callback:T):Int {
        return callbacks.push(callback);
    }

    /**
        Unsubscribe callback on event

        @param callback callback itself
    **/
    public function unsubscribe(callback:T):Bool {
        return callbacks.remove(callback);
    }

    /**
        Return true, if event have at lease one handler

        @return true if event have handlers
    **/
    public function is_exist():Bool {
        return callbacks.length > 0;
    }

    /**
        Clear the all event handlers
    **/
    public function clear():Void {
        callbacks = [];
    }

    /**
        Trigger the event and call all subscribed callbacks

        @param params all event params
    **/
    public function trigger(?args:Array<Dynamic>):Void {
        for (i in callbacks) {
            Reflect.callMethod(null, i, args);
        }
    }

    private var callbacks:Array<T>;
}