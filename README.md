# Haxe support library for the [Druid](https://github.com/Insality/druid) Defold component UI library

## Features

+ Based on [hxdefold](https://github.com/hxdefold/hxdefold), so we have every features of hxdefold :D
+ Object-oriented programming

## Quick start

### Install hxdefold

Document at [https://github.com/hxdefold/hxdefold#quick-start](https://github.com/hxdefold/hxdefold#quick-start)

### Install hxdruid

+ Install this library (from this repo): `haxelib git https://github.com/phi-x/hxdruid`
+ Add two lines to your `build.hxml`:
```hxml
...
-lib hxdefold
# enable hxdruid Haxe library       <=== NEW
-lib hxdruid                        <=== NEW
# enable full dead code elimination
...
```
+ Enjoy!

## Note

You do NOT need to add druid to your defold dependencies. This is a Haxe-REWRITE.

## Example
```haxe
import druid.*;

typedef HelloData = {};

class Hello extends DruidScript<HelloData> {
    private function hover_callback(self:HelloData, state:Bool) {
        trace(state);
    }

    override function init(self:HelloData) {
        super.init(self);
        druid.add(new Hover("hover", hover_callback));
    }
}
```

## Document

Coming soon.

## Contribute

Issues and PRs are welcomes.

## Todo List

+ [x] Basic framework
+ [ ] Builtin components (1/17)
