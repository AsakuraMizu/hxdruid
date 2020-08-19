package druid;

@:luaRequire("utf8")
extern class Utf8 {
    static function sub(s:String, i:Int, ?j:Int):String;
    static function gmatch(str:String, regex:String, ?all:Bool):Void -> String;
}