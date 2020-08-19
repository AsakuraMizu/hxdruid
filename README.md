# Haxe support library for the [Druid](https://github.com/Insality/druid) Defold component UI library

## Features

## Quick start

### Install hxdefold

Document at [https://github.com/hxdefold/hxdefold#quick-start](https://github.com/hxdefold/hxdefold#quick-start)

### Install hxdruid

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
        add(new Hover("hover", hover_callback));
    }
}
```

## Documentation

## Contribution

Issues and PRs are welcomed.

## Todo List

+ [x] Base framework
+ [x] Basic components (17/17)
+ [ ] Guide & Documentation
+ [ ] Test all components
+ [ ] Advanced style system
+ [ ] Examples
