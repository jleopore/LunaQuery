<img src="https://github.com/jleopore/LunaQuery/raw/master/docs/logo.png" align="left" width="120" />

# LunaQuery
Fluent, Linq-Style Query Expressions for Lua

## Installation
With LuaRocks:
```sh
LuaRocks install LunaQuery
```
Otherwise, just copy LunaQuery.lua to your project directory or lua path.

## Import
```lua
Enumerable = (require 'LunaQuery').Enumerable
```

## Methods

### `aggregate(accumulator, initialValue)`

Applies an accumulator function over each element, beginning with an initial value.

* `accumulator` is a function which takes two parameters.
* `initialValue` must be the same as the return type

Examples:
```
---
```

...
