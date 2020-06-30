<img src="https://github.com/jleopore/LunaQuery/raw/master/docs/buttonLogo.png" align="left" width="120" />

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
Enumerable = require 'LunaQuery'
```

## Methods

:waning_crescent_moon: All Methods take *self* as the initial parameter.

| aggregate <br> all <br> any <br> append <br> average <br> concat <br> contains <br> count <br> defaultIfEmpty <br> distinct <br> elementAt <br> elementAtOrDefault <br> empty <br> except <br> first <br> firstOrDefault <br> forEach <br> fromDictionary <br> fromHashSet <br> fromList | groupBy <br> groupJoin <br> intersect <br> join <br> last <br> lastOrDefault <br> max <br> min <br> ofType <br> orderBy <br> orderByDescending <br> prepend <br> range <br> repeatElement <br> reverse <br> select <br> selectMany <br> sequenceEqual <br> single <br> singleOrDefault | skip <br> skipLast <br> skipWhile <br> sum <br> take <br> takeLast <br> takeWhile <br> thenBy <br> thenByDescending <br> toArray <br> toDictionary <br> toEnumerable <br> toHashSet <br> toList <br> toLookup <br> union <br> where <br> zip <br> <br> <br> |
|  :--  | :-- | :-- |

### `aggregate(accumulator, initialValue)`

Applies an accumulator function over each element, beginning with an initial value.

* `accumulator` is a function which takes two parameters.
* `initialValue` must be the same as the return type

Examples:
```
---
```

...
