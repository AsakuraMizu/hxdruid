package druid.types;

import defold.types.Hash;

abstract Interest(Hash) to Hash {
    public inline function new(s:String) this = Defold.hash(s);
}