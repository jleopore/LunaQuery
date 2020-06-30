<img src="https://github.com/jleopore/LunaQuery/raw/master/docs/buttonLogo2.png" align="left" width="120" />

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

> :waning_crescent_moon: All Methods take *self* as the initial parameter.

| aggregate <br> all <br> any <br> append <br> average <br> concat <br> contains <br> count <br> defaultIfEmpty <br> distinct <br> elementAt <br> elementAtOrDefault <br> empty <br> except <br> first <br> firstOrDefault <br> forEach <br> fromDictionary <br> fromHashSet <br> fromList | groupBy <br> groupJoin <br> intersect <br> join <br> last <br> lastOrDefault <br> max <br> min <br> ofType <br> orderBy <br> orderByDescending <br> prepend <br> range <br> repeatElement <br> reverse <br> select <br> selectMany <br> sequenceEqual <br> single <br> singleOrDefault | skip <br> skipLast <br> skipWhile <br> sum <br> take <br> takeLast <br> takeWhile <br> thenBy <br> thenByDescending <br> toArray <br> toDictionary <br> toEnumerable <br> toHashSet <br> toList <br> toLookup <br> union <br> where <br> zip <br> <br> <br> |
|  :--  | :-- | :-- |

### `aggregate(accumulator, initialValue)`

**Applies an accumulator function over each element, beginning with an initial value**

* `accumulator` is a function which takes two parameters.
* `initialValue` must be the same as the return type

Examples:
```
---
```

...

### `all(predicate)`

**Returns true if the predicate is true for every element**

* `predicate` is a function with a single parameter.

Examples:
```
---
```

### `any(predicate = defaultPredicate)`

**Returns true if the predicate is true for at least one element**

* `predicate` is a function with a single parameter. The default predicate always returns true.

Examples:
```
---
```

### `append(element)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### `average(selector = defaultSelector)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```
    
### `concat(second)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### `contains(value, equalComparer = defaultEqualComparer)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### `count(predicate = defaultPredicate)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### `defaultIfEmpty(default)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### `distinct(equalComparer = defaultEqualComparer)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### `elementAt(index)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### `elementAtOrDefault(index, default)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### `empty()`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### `except(second, equalComparer = defaultEqualComparer)`

Distinct elements in this enum but not in the second.

* `second` is a param.
* `equalComparer` is a param.

Examples:
```
---
```
  
### `first(predicate = defaultPredicate)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### `firstOrDefault(default, predicate = defaultPredicate)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### `forEach(action)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

---create enumerable from table of unordered key-value pairs
### `fromDictionary(table)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

---create enumerable from a table of unordered keys
### `fromHashSet(table)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

---create enumerable from an integer-indexed array-like table
### `fromList(table)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```
  
--- keyselector takes a value and produces a key to compare
--    Enumerable({cat, horse, dog, pig, sheep, whale})
--      \groupBy((name) -> #name)
-- output should look like..
-- {
--   [1]{[3]{cat, dog, pig}}
--   [2]{[5]{horse, sheep, whale}}
-- }
-- 
### `groupBy(keySelector, valueSelector = defaultSelector, resultSelector = defaultResultSelector,equalComparer = defaultEqualComparer)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### `groupJoin(inner, outerSelector, innerSelector, resultSelector, equalComparer =defaultEqualComparer)`

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### intersect(second, equalComparer = defaultEqualComparer)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

--Wherever a keyselector from list 1 matches a keyselector from list 2, add an item to the result.
### join(inner, outerSelector, innerSelector, resultSelector, equalComparer = defaultEqualComparer) =>

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### last(predicate = defaultPredicate)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### lastOrDefault(default, predicate = defaultPredicate)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### max(selector = defaultSelector)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### min(selector = defaultSelector) 

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### ofType(whichType)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### orderBy(keySelector = defaultSelector, comparer = defaultComparer) 

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### orderByDescending(keySelector = defaultSelector, comparer = defaultComparer) 

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### prepend(element)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### range(start, count) => @@([i for i=start, start + count - 1])

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### repeatElement(element, count) 

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### reverse

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### select(selector)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### selectMany(collectionSelector, resultSelector = defaultSelector)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### sequenceEqual(second, equalComparer = defaultEqualComparer)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### single(predicate = defaultPredicate)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### singleOrDefault(default, predicate = defaultPredicate)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### skip(count)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### skipLast(count)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

--Go through the list in a single iteration.
### skipWhile(predicate)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### sum(selector = defaultSelector)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### take(count)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### takeLast(count) =>

Description goes here.

* `predicate` is a param.

Examples:
```
---
```
### takeWhile(predicate)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### thenBy(keySelector = defaultSelector, comparer = defaultComparer)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### thenByDescending(keySelector = defaultSelector, comparer = defaultComparer)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### toArray

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### toDictionary(keySelector, valueSelector = defaultSelector) 

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### toEnumerable

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### toHashSet

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### toList

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### toLookup(keySelector, valueSelector = defaultSelector)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### union(second, equalComparer = defaultEqualComparer) 

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

### where(predicate)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```

--two collections
### zip(second, resultSelector = defaultResultSelector)

Description goes here.

* `predicate` is a param.

Examples:
```
---
```
