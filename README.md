<img src="https://github.com/jleopore/LunaQuery/raw/master/docs/buttonLogo2.png" align="left" width="120" />

# LunaQuery
Fluent, Linq-Style Query Expressions for Lua

## Installation
With LuaRocks:
```sh
LuaRocks install LunaQuery
```
Otherwise, just copy LunaQuery.lua to your project directory or lua path.

## Usage
### Import
```lua
Enumerable = require 'LunaQuery'
```

### Lambda Expressions
Many methods take one or more functions as parameters. For convenience, these can be written as lambda expression strings, with comma-separated parameter names and a thin arrow, followed by the expression to return.

The following are equivalent:
```lua
local function negativize (n) 
  return -n 
end

--Using External Functions
local e = Enumerable{1,2,3,4}
  :skip(2)
  :select(negativize) --local externally-declared function
  :forEach(print)     --global function

--Using Inline Functions
local e = Enumerable{1,2,3,4}
  :skip(2)
  :select(function(a) return -a end)        --anonymous function
  :forEach(function(a) return print(a) end) --anonymous function

--Using Lambda Expressions
local e = Enumerable{1,2,3,4}
  :skip(2)
  :select('(a) -> -a')        -- inline string
  :forEach('(a) -> print(a)') -- inline string
```
```
-3
-4
```
> Note: all functions parsed from lambda strings will be scoped globally-- If your function needs to access local variables, don't specify it as a string.
```lua
local function negativize (n) 
  return -n 
end

--Don't Do This
local e = Enumerable{1,2,3,4}
  :skip(2)
  :select('(a) -> negativize(a)') -- ERROR: lambda strings can't reference locals!
  :forEach('(a) -> print(a)') -- print() is global, so this is OK
```

## Methods  (Documentation under development)

> :waning_crescent_moon: All Methods take *self* as the initial parameter.

| [aggregate](#aggregate) <br> [all](#all) <br> [any](#any) <br> [append](#append) <br> [average](#average) <br> [concat](#concat) <br> [contains](#contains) <br> [count](#count) <br> defaultIfEmpty <br> distinct <br> elementAt <br> elementAtOrDefault <br> empty <br> except <br> first <br> firstOrDefault <br> forEach <br> fromDictionary <br> fromHashSet <br> fromList | groupBy <br> groupJoin <br> intersect <br> join <br> last <br> lastOrDefault <br> max <br> min <br> ofType <br> orderBy <br> orderByDescending <br> prepend <br> range <br> repeatElement <br> reverse <br> select <br> selectMany <br> sequenceEqual <br> single <br> singleOrDefault | skip <br> skipLast <br> skipWhile <br> sum <br> take <br> takeLast <br> takeWhile <br> thenBy <br> thenByDescending <br> toArray <br> toDictionary <br> toEnumerable <br> toHashSet <br> toList <br> toLookup <br> union <br> where <br> zip <br> <br> <br> |
|  :--  | :-- | :-- |

### <a id="aggregate">`aggregate(accumulator, initialValue)`</a>

**Applies an accumulator function over each element, beginning with an initial value**

* `accumulator` is a function which takes two parameters.
* `initialValue` must be the same as the return type

Examples:
```lua
numberString = Enumerable{1,2,3}:aggregate('(a,b) -> a .. tostring(b)', '')
print(numberString)
```
`123`

### `all(predicate)`  <a id="all"></a>

**Returns true if the predicate is true for every element**

* `predicate` is a function with a single parameter.

Examples:
```lua
allOddNumbers = Enumerable{1,3,4,5}:all('(n) -> n % 2 == 1')
print(allOddNumbers)
```
`false`

### `any(predicate = defaultPredicate)` <a id="any"></a>

**Returns true if the predicate is true for at least one element**

* `predicate` is a function with a single parameter. The default predicate always returns true.

Examples:
```lua
emptySetHasMembers = Enumerable{}:any()
print(emptySetHasMembers)
``` 
`false`
```lua
nonemptySetHasMembers = Enumerable{'zxcvbn'}:any()
print(nonemptySetHasMembers)
```
`true`
```lua
anyOddNumbers = Enumerable{1,3,4,5}:any('(n) -> n % 2 == 1')
print(anyOddNumbers)
```
`true`

### `append(element)` <a id="append"></a>

**Adds a single element to the end of the sequence**

Examples:
```lua
oneMore = Enumerable{'una', 'vez'}
            :append('mas')
            :forEach(print)
```
```
una
vez
mas
```

### `average(selector = defaultSelector)` <a id="average"></a>

**Sum of the sequence divided by the count**

* `selector` is a single-parameter function of each element. The default selector returns each element unchanged.

Examples:
```lua
averageNumbers = Enumerable{1,2,3,4}:average()
print(averageNumbers)
```
`2.5`

```lua
averageNameLength = Enumerable{'thomas', 'richard', 'harold'}:average('(a) -> #a')
print(averageNameLength)
```
`6.3333333333333`
    
### `concat(second)`  <a id="concat"></a>

**Concatenates another sequence onto the end of this one**

* `second` is another `Enumerable`

Examples:
```lua
Enumerable{'lettuce', 'meat', 'tomato'}
  :concat(Enumerable{'onion', 'pickles'})
  :forEach(print)
```
```
lettuce
meat
tomato
onion
pickles
```

### `contains(value, equalComparer = defaultEqualComparer)` <a id="contains"></a>

Returns true if one or more elements is equal to the provided value

* `equalComparer` is a two-parameter function returning true or false.

Examples:
```lua
hasWheat = Enumerable{'rice', 'beans', 'squash'}:contains('wheat')
print(hasWheat)
```
`false`
```lua
inventory = Enumerable{
  {
    id = 80153,
    type = 'book',
    title = 'The Hobbit'
  },
  {
    id = 94532,
    type = 'book',
    title = 'Snow Crash'
  }
}

desiredBook = {
  type = 'book',
  title = 'The Hobbit'
}

inStock = inventory:contains(desiredBook, '(a,b) -> a.title == b.title')
print(inStock)
```
`true`

### `count(predicate = defaultPredicate)` <a id="count"></a>

Description goes here.

* `predicate` is a param.

Examples:
```lua
fowlCount = Enumerable{'duck', 'duck', 'duck', 'duck', 'goose'}
              :count()
print(fowlCount)
```
`5`
```lua
ducksOnly = Enumerable{'duck', 'duck', 'duck', 'duck', 'goose'}
              :count('(bird) -> bird == "duck"')
print(ducksOnly)
```
`4`
