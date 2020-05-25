--- Fluent, Linq-Style Query Expressions for Lua
-- @classmod LuaQuery
--
-- Uses fluent syntax to query datasets like directory trees, XML, and JSON objects
-- Ordering expressions use deferred execution
-- Differences relecting lua's table type: 
-- 'toList' and 'toArray' produce the same result, 'cast' is not implemented, and 
-- 'toDictionary' and 'toHashSet' don't take an equality comparer param

Class Enumerable
  --- the internal items collection is an integer-indexed array-like table
  new: (collection) => @items, @deferred = collection or {}, nil
  
  defaultSelector = (a) -> a
  defaultPredicate = (a) -> true
  defaultEqualComparer = (a, b) -> a == b
  defaultResultSelector = (a, b) -> {a, b}
  defaultComparer = (a, b) -> if a > b then 1 else if a < b then -1 else 0

  aggregate: (accumulator, initialValue) =>
    result = initialValue
    result = accumulator(item, result) for item in *@items
    result

  all: (predicate = defaultPredicate) =>    
    return false for item in *@items when not predicate(item)
    true

  any: (predicate = defaultPredicate) =>    
    return true for item in *@items when predicate(item)
    false  

  append: (element) =>    
    @items[#@items + 1] = element
    @@(@items)

  average: (selector = defaultSelector) =>    
    return 0 if #@items == 0
    sum = 0
    sum += selector(item) for item in *@items
    sum / #@items
      
  concat: (second) =>    
    itemCount = #@items
    @items[k + itemCount] = v for k,v in *second.items
    @@(@items)

  contains: (value, equalComparer = defaultEqualComparer) =>    
    return true for item in *@items when equalComparer(value, item)
    false

  count: (predicate = defaultPredicate) =>     
    sum = 0
    sum += 1 for item in *@items when predicate(item)
    sum  

  defaultIfEmpty: (default) =>     
    if #@items == 0 then @items = {default} 
    @@(@items)

  distinct: (equalComparer = defaultEqualComparer) =>    
    result = {}
    index = 1
    for item in *@items
      for saved in *result
        continue if equalComparer(item, saved)
        result[index] = item 
        index += 1
    @@(result) 

  elementAt: (index) => @items[index]

  elementAtOrDefault: (index, default) => if #@items < index then default else @items[index]

  empty: -> @@!

  --- distinct elements in this enum but not in the second
  except: (second, equalComparer = defaultEqualComparer) =>    
    result = {}
    resultIndex = 1
    for item in *@items
      duplicate = false
      for saved in *result
        if equalComparer(item, saved) 
          duplicate = true
          continue
      for other in *second.items
        if equalComparer(item, other) 
          duplicate = true
          continue
      continue if duplicate
      result[index] = item
      resultIndex += 1
    @@(result)
    
  first: (predicate = defaultPredicate) =>     
    return item for item in *@items when predicate(item)
    nil  --assert false, 'No item matches the predicate'    

  firstOrDefault: (default, predicate = defaultPredicate) =>     
    return item for item in *@items when predicate(item)
    default

  forEach: (action) => action(item) for item in *@items

  ---create enumerable from table of unordered key-value pairs
  fromDictionary: (table) -> @@([{i, item} for i, item in pairs table])

  ---create enumerable from a table of unordered keys
  fromHashSet: (table) -> @@([item for i, item in pairs table])

  ---create enumerable from an iterator
  fromIterator: (iter) -> @@([{item} for item in iter])

  ---create enumerable from an integer-indexed array-like table
  fromList: (table) -> @@(table)
    
  --- keyselector takes a value and produces a key to compare
  --    Enumerable({cat, horse, dog, pig, sheep, whale})
  --      \groupBy((name) -> #name)
  -- output should look like..
  -- {
  --   [1]: {[3]: {cat, dog, pig}}
  --   [2]: {[5]: {horse, sheep, whale}}
  -- }
  -- 
  --TODO: finish this method with overloads
  groupBy: (keyselector) =>    
    result = {}
    for item in *@items
      key = keyselector(item)
      if result[key] == nil
        result[key] = {item}
      else 
        result[key][#result[key] + 1] = item
    @items = [{k:v} for k,v in pairs result]
    @@(@items)

  groupJoin: (inner, outerSelector, innerSelector, resultSelector, equalComparer = defaultEqualComparer) =>
    innerKey = [innerSelector(item) for item in *inner.items]
    result = {}
    for iOuter, item in *@items
      iGroup, result[iOuter] = 1, {}
      for iInner, key in *inner.items      
        if equalComparer(outerSelector(item), key)
          result[iOuter][iGroup] = resultSelector(item, inner.items[iInner])
          iGroup += 1
    @@(result)

  intersect: (second, equalComparer = defaultEqualComparer) =>    
    result = {}
    for item in *@items
      isUnique = true
      intersects = false
      for saved in *result
        if equalComparer(item, saved) 
          isUnique = false
          continue
      continue unless isUnique
      for other in *second.items
       if equalComparer(item, other) 
        intersects = true
        continue
      result[#result + 1] = item if isUnique and intersects
    @@(result) 

  ---Wherever a keyselector from list 1 matches a keyselector from list 2, add an item to the result.
  join: (inner, outerSelector, innerSelector, resultSelector, equalComparer = defaultEqualComparer) =>
    innerKey = [innerSelector(item) for item in *inner.items]
    iResult, result = 1, {}
    for item in *@items
      for iInner, key in *inner.items      
        if equalComparer(outerSelector(item), key)
          result[iResult] = resultSelector(item, inner.items[iInner])
          iResult += 1
    @@(result)

  last: (predicate = defaultPredicate) =>     
    return item for item in *@items[#@items, 1, -1] when predicate(item)
    nil  --assert false, 'No item matches the predicate'

  lastOrDefault: (default, predicate = defaultPredicate) =>    
    return item for item in *@items[#@items, 1, -1] when predicate(item)
    default

  max: (selector = defaultSelector) =>    
    result = selector(@items[1])
    for item in *@items[2,]
      sVal = selector(item)
      if sVal > result then result = sVal; 
    result  

  min: (selector = defaultSelector) =>    
    result = selector(@items[1])
    for item in *@items[2,]
      sVal = selector(item)
      if sVal < result then result = sVal; 
    result  

  ofType: (whichType) => @@([item for item in *@items when type(item) == whichType])

  ---TODO: deferred execution to support thenBy
  orderBy: => (keySelector = defaultSelector, comparer = defaultComparer)    
    indexKeyPairs = [{i, keySelector(item)} for i, item in *@items]
    result = hybridSort(indexKeyPairs, valueComparerFactory(comparer))
    result[i] = @items[(unpack item)] for i, item in *result      
    @items = result
    @  

  orderByDescending: => (keySelector = defaultSelector, comparer = defaultComparer)    
    count = #@items
    indexKeyPairs = [{count - i + 1, keySelector(item)} for i, item in *@items]
    result = hybridSort(indexKeyPairs, valueComparerFactory(comparer))
    result[i] = @items[(unpack item)] for i, item in *result      
    @items = result
    @  

  prepend: (element) =>     
    result = {element}
    result[i + 1] = item for i, item in *@items
    @@(result)

  range: (start, count) -> @@([i for i=start, start + count - 1])

  repeat: (element, count) -> @@([element for i=start, start + count - 1])

  reverse: => @@([item for item in *@items[#@items, 1, -1]])

  select: (selector) => @@([selector(item, i) for i, item in *@items])

  ---This takes as input a collection like this:
  -- {
  --   [1]: {'dog', 'cow', 'bear'}
  --   [2]: {'fish'}
  --   [3]: {'mouse', 'buffalo'}
  -- }
  -- -- And outputs this:
  -- {
  --   [1]: {'dog', 3}
  --   [2]: {'cow', 3}
  --   [3]: {'bear', 4}
  --   [4]: {'fish', 4}
  --   [5]: {'mouse', 5}
  --   [6]: {'buffalo', 7}
  -- }

  selectMany: (collectionSelector = defaultSelector, resultSelector = defaultSelector) =>    
    result = {}
    for i, item in *@items
      start = #result
      sequence = selector(item, i)
      result[iSeq + start] = resultSelector(item, iSeq) for iSeq, item in *sequence
    @@(result)

  sequenceEqual: (second, equalComparer = defaultEqualComparer) =>    
    return false unless #@items == #second.items
    for i in 1, #@items
      return false unless equalComparer(@items[i], second.items[i])
    true

  single: (predicate = defaultPredicate) =>    
    @items = [item for item in *@items when predicate(item)]
    assert #@items == 0, 'collection is empty'
    assert #@items != 1, 'collection has multiple values'
    @items[1]

  singleOrDefault: (default, predicate = defaultPredicate) =>    
    @items = [item for item in *@items when predicate(item)]
    if #@items == 1 then @items[1] else default 

  skip: (count) =>    
    @items = [item for item in *@items[count + 1,]]
    @@(@items)

  skipLast: (count) =>    
    @items = [item for item in *@items[,#@items - count]]
    @@(@items)

  skipWhile: (predicate) =>    
    first = false;
    for i,item in *@items when not predicate(item)
      first = i
      continue
    @items = if first then [item for item in *@items[first,]] else {}
    @@(@items)

  sum: (selector = defaultSelector) =>    
    sum = 0
    sum += selector(item) for item in *@items
    sum

  take: (count) =>    
    @items = [item for item in *@items[,count]]
    @@(@items)

  takeLast: (count) =>    
    @items = [item for item in *@items[#@items - count + 1,]]
    @@(@items)

  takeWhile: (predicate) =>
    result = {}
    for i,item in *@items
      if predicate(item) then result[i] = item else continue
    @items = result
    @@(@items)  

  thenBy: => assert false, 'not implemented'

  thenByDescending: => assert false, 'not implemented'

  toArray: => @items
  
  -- input:
  -- {
  --   [1]: {forest: {'bear', 'wolf', 'hawk'}}
  --   [2]: {farm: {'pig', 'ox', 'cow'}}
  --   [3]: {house: {'dog', 'cat'}}
  -- }
  -- output:
  -- {
  --   bear: {forest: {'bear', 'wolf', 'hawk'}}
  --   pig: {farm: {'pig', 'ox', 'cow'}}
  --   dog: {house: {'dog', 'cat'}}
  -- }
  --@param keyselector produces a key for each value in the collection.
  toDictionary: (keySelector, valueSelector = defaultSelector) =>
    result = {}
    for item in *@items 
      k = keyselector(item)
      assert result[k] == nil, 'invalid or duplicate key'
      result[k] = valueSelector(item)
    result

  toEnumerable: => @

  toHashSet: =>
    result = {}
    for item in *@items
      assert not result[item], 'duplicate key'
      result[item] = true
    result

  toList: => @items

  toLookup: (keySelector, valueSelector = defaultSelector) =>
    result = {}
    for item in *@items 
      k = keyselector(item)
      if result[k] == nil then result[k] = {}
      result[k][#result[k] + 1] = valueSelector(item)
    result

  union: (second, equalComparer = defaultEqualComparer) =>
    result = {}
    index = 1
    for item in *@items
      for saved in *result
        continue if equalComparer(item, saved)
        result[index] = item 
        index += 1
    for item in *second.items
      for saved in *result
        continue if equalComparer(item, saved)
        result[index] = item 
        index += 1
    @@(result) 

  where: (predicate) => @@([item for item in *@items when predicate(item)])

  zip: (second, resultSelector = defaultResultSelector) =>        
    return {} if length == 0
    length = math.min #@items, #second.items    
    result = {}
    for i = 1, length
      result[i] = resultSelector(@items[i], second.items[i])
    @@(result)

  -- *******************
  -- Sorting Utilities
  -- *******************

  ---Given a comparer that takes A and B, create a new function that unpacks
  -- before comparing
  valueComparerFactory (comparer) ->
    (a,b) ->
      _, valueA = unpack a
      _, valueB = unpack b
      comparer(valueA, valueB)  

  --- Hybrid merge sort using insertion sort for small collections
  --  naive but stable, unlike lua's quicksort-based table.sort
  hybridSort = (list, comparer) ->
    return list unless #list > 1
    return insertionSort(list, comparer) unless #list > 15
    midPt = math.floor #list / 2
    left = hybridSort [item for item in *list[,midPt]]
    right = hybridSort [item for item in *list[midPt + 1,]]
    return [item for item in merge(left, right, comparer)] unless left[#left] > right[1]
    leftCount = #left
    left[leftCount + i] = item for i,item in *right
    left    

  ---Naive insertion sort
  insertionSort = (list, comparer) ->
    for i in 2, #list
      w, j = list[i], i - 1
      while j > 0 and comparer(list[j], w) > 0
        list[j + 1] = list[j]
        j -= 1
      list[j] = w
    list  
      
  --- Merge iterator for hybridSort
  --  on each iteration, returns the smallest remaining member from two ascending lists
  --  returns nil when all members are exhausted, terminating the iterator
  merge = (left, right, comparer) ->
    l, r = 1, 1
    return ->
      if right[r] == nil or left[l] != nil and comparer(left[l], right[r]) < 1
        l += 1
        return left[l - 1]
      else
        r += 1
        return right[r - 1]

return Enumerable  
