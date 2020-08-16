package druid.base;

import defold.support.ScriptOnInputAction;
import defold.types.Hash;

/**
    Component to handle back key (android, backspace)
**/
class BackHandler<T:{}, PT> extends Component<T> {
    /**
        On back handler callback
    **/
    public var on_back(default, null):Event<(T, PT) -> Void>;

    /**
        Params to click callbacks
    **/
    public var params:PT;

    /**
        Component constructor

        @param callback Callback On back button
        @param params Callback argument
    **/
    public function new(callback:(T, PT) -> Void, ?params:PT) {
        name = "BackHandler";
        interest = [Const.ON_INPUT];

        this.params = params;
        on_back = new Event(callback);
    }

    override function on_input(action_id:Hash, action:ScriptOnInputAction):Bool {
        if (!action.released)
            return false;

        if (action_id == Const.ACTION_BACK || action_id == Const.ACTION_BACKSPACE) {
            on_back.trigger([context, params]);
            return true;
        }
        
        return false;
    }
}