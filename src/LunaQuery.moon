--- Fluent, Linq-Style Query Expressions for Lua

-- Uses fluent syntax to query datasets like directory trees, XML, and JSON objects
-- Differences relecting lua's table type: 
-- 'toList' and 'toArray' produce the same result, 'cast' is not implemented, and 
-- 'toDictionary' and 'toHashSet' don't take an equality comparer param
-- 'repeat' is renamed 'repeatElement' to avoid collision with lua's repeat keyword
local *
class Enumerable
  new: (collection, count, orderedBy) => 
    @items = collection
    @length = count or #collection
    @orderedBy = orderedBy or 0
  
  defaultSelector = (a) -> a
  defaultPredicate = (a) -> true
  defaultEqualComparer = (a, b) -> a == b
  defaultResultSelector = (a, b) -> {a,b}
  defaultComparer = (a, b) -> if a > b then 1 else if a < b then -1 else 0

  iter = => enumerate(@items, @orderedBy)
  iterPairs = => enumeratePairs(@items, @orderedBy)

  aggregate: (accumulator, initialValue) =>
    accumulator = getFunction(accumulator)
    result = initialValue
    result = accumulator(result, item) for item in iter(@)
    result

  all: (predicate) =>
    predicate = getFunction(predicate)
    return false for item in iter(@) when not predicate(item)
    true

  any: (predicate = defaultPredicate) =>
    predicate = getFunction(predicate)
    return true for item in iter(@) when predicate(item)
    false  

  append: (element) =>
    result = @toArray!
    result[#result + 1] = element
    @@(result)

  average: (selector = defaultSelector) =>
    selector = getFunction(selector)
    sum, count = 0, 0    
    for item in iter(@)
      sum += selector(item) 
      count += 1
    if count == 0 then return 0 
    sum / count
      
  concat: (second) =>
    result = @toArray!
    itemCount = #result
    result[i + itemCount] = item for i,item in iterPairs(second)
    @@(result)  

  contains: (value, equalComparer = defaultEqualComparer) =>
    equalComparer = getFunction(equalComparer)
    return true for item in iter(@) when equalComparer(value, item)
    false

  count: (predicate = defaultPredicate) =>
    predicate = getFunction(predicate)
    sum = 0
    sum += 1 for item in iter(@) when predicate(item)
    sum  

  defaultIfEmpty: (default) => if iter(@)! == nil then return @@({default}) else return @@(@items)

  distinct: (equalComparer = defaultEqualComparer) =>
    equalComparer = getFunction(equalComparer)
    result = {}
    index = 1
    for item in iter(@)
      duplicate = false
      for saved in *result
        duplicate = true if equalComparer(item, saved)
      unless duplicate
        result[index] = item 
        index += 1
    @@(result)

  elementAt: (index) => 
    return item for i,item in iterPairs(@) when i == index
    assert false, 'No element at the given index'

  elementAtOrDefault: (index, default) => 
    return item for i,item in iterPairs(@) when i == index
    default

  empty: => @@({})

  --- distinct elements in this enum but not in the second
  except: (second, equalComparer = defaultEqualComparer) =>
    equalComparer = getFunction(equalComparer)
    result, i = {}, 1
    for item in iter(@)
      duplicate = false
      for saved in *result
        if equalComparer(item, saved)
          duplicate = true
          break
      unless duplicate
        for other in iter(second)
          if equalComparer(item, other) 
            duplicate = true
            break
      continue if duplicate
      result[i] = item
      i += 1
    @@(result)
    
  first: (predicate = defaultPredicate) =>
    predicate = getFunction(predicate)
    return item for item in iter(@) when predicate(item)
    assert false, 'No item matches the predicate'

  firstOrDefault: (default, predicate = defaultPredicate) =>
    predicate = getFunction(predicate)
    return item for item in iter(@) when predicate(item)
    default

  forEach: (action) => 
    action = getFunction(action)
    action(item) for item in iter(@)

  ---create enumerable from table of unordered key-value pairs
  fromDictionary: (table) => @@([{k,v} for k,v in pairs table])

  ---create enumerable from a table of unordered keys
  fromHashSet: (table) => @@([k for k,v in pairs table])

  ---create enumerable from an integer-indexed array-like table
  fromList: (table) => @@([item for item in *table])
    
  --- keyselector takes a value and produces a key to compare
  --    Enumerable({cat, horse, dog, pig, sheep, whale})
  --      \groupBy((name) -> #name)
  -- output should look like..
  -- {
  --   [1]: {[3]: {cat, dog, pig}}
  --   [2]: {[5]: {horse, sheep, whale}}
  -- }
  -- 
  groupBy: (keySelector, valueSelector = defaultSelector, resultSelector = defaultResultSelector, equalComparer = defaultEqualComparer) =>
    keySelector = getFunction(keySelector)
    valueSelector = getFunction(valueSelector)
    resultSelector = getFunction(resultSelector)
    equalComparer = getFunction(equalComparer)
    result = {}
    for item in iter(@)
      key = keySelector(item)
      duplicateKey = false
      for i, existingKVs in ipairs result
        existingKey = existingKVs[1]
        if equalComparer(existingKey, key)
          duplicateKey = true
          existingValues = result[i][2]
          existingValues[#existingValues + 1] = valueSelector(item)
          break
      unless duplicateKey
        result[#result + 1] = {key, {valueSelector(item)}}
    @@([resultSelector(kv[1], kv[2]) for kv in *result])

  groupJoin: (inner, outerSelector, innerSelector, resultSelector, equalComparer = defaultEqualComparer) =>
    outerSelector = getFunction(outerSelector)
    innerSelector = getFunction(innerSelector)
    resultSelector = getFunction(resultSelector)
    equalComparer = getFunction(equalComparer)
    keyedInner = [{innerSelector(item), item} for item in iter(inner)]
    result = {}
    for i, oItem in iterPairs(@)
      outerKey = outerSelector(oItem)
      group, groupIndex = {}, 1
      for iKeyVal in *keyedInner
        innerKey, innerItem = iKeyVal[1], iKeyVal[2]
        if equalComparer(outerKey, innerKey) --if outerselector and innerselector keys match..
          group[groupIndex] = innerItem
          groupIndex += 1
      result[i] = resultSelector(oItem, group)
    @@(result)    

  intersect: (second, equalComparer = defaultEqualComparer) =>
    equalComparer = getFunction(equalComparer)
    result = {}
    for item in iter(@)
      isUnique = true
      intersects = false
      for saved in *result
        if equalComparer(item, saved) 
          isUnique = false
          break
      continue unless isUnique
      for other in iter(second)
       if equalComparer(item, other) 
        intersects = true
        break
      result[#result + 1] = item if isUnique and intersects
    @@(result)

  --Wherever a keyselector from list 1 matches a keyselector from list 2, add an item to the result.
  join: (inner, outerSelector, innerSelector, resultSelector, equalComparer = defaultEqualComparer) =>
    outerSelector = getFunction(outerSelector)
    innerSelector = getFunction(innerSelector)
    resultSelector = getFunction(resultSelector)
    equalComparer = getFunction(equalComparer)    
    keyedInner = [{innerSelector(item), item} for item in iter(inner)]
    iResult, result = 1, {}
    for item in iter(@)
      for iKeyVal in *keyedInner
        ikey, iItem = iKeyVal[1], iKeyVal[2]
        if equalComparer(outerSelector(item), ikey)
          result[iResult] = resultSelector(item, iItem)
          iResult += 1
    @@(result)

  last: (predicate = defaultPredicate) =>
    predicate = getFunction(predicate)
    result = nil
    result = item for item in iter(@) when predicate(item)      
    return result unless result == nil
    assert false, 'No item matches the predicate'

  lastOrDefault: (default, predicate = defaultPredicate) =>
    predicate = getFunction(predicate) 
    result = default
    result = item for item in iter(@) when predicate(item)
    result

  max: (selector = defaultSelector) =>
    selector = getFunction(selector)
    getItem = iter(@)
    result = selector(getItem!)
    for i = 2, @length
      sVal = selector(getItem!)
      if sVal > result then result = sVal
    result

  min: (selector = defaultSelector) =>
    selector = getFunction(selector) 
    getItem = iter(@)
    result = selector(getItem!)
    for i = 2, @length
      sVal = selector(getItem!)
      if sVal < result then result = sVal
    result

  ofType: (whichType) => @@([item for item in iter(@) when type(item) == whichType])

  orderBy: (keySelector = defaultSelector, comparer = defaultComparer) =>
    keySelector = getFunction(keySelector)
    comparer = getFunction(comparer)
    @@(sortAndGroup([item for item in iter(@)], 0, keySelector, comparer), @length, 1)

  orderByDescending: (keySelector = defaultSelector, comparer = defaultComparer) =>
    keySelector = getFunction(keySelector)
    comparer = getFunction(comparer)
    @@(sortAndGroup([item for item in iter(@)], 0, keySelector, comparer, true), @length, 1)

  prepend: (element) =>     
    result = {element}
    result[i + 1] = item for i, item in iterPairs(@)
    @@(result)

  range: (start, count) => @@([i for i=start, start + count - 1])

  repeatElement: (element, count) => @@([element for i=1,count])

  reverse: => 
    result, r = {}, @length + 1
    for i,item in iterPairs(@)
      result[r - i] = item
    @@(result)
 
  select: (selector) => 
    selector = getFunction(selector)
    @@([selector(item, i) for i, item in iterPairs(@)])

  selectMany: (collectionSelector, resultSelector = defaultSelector) =>
    collectionSelector = getFunction(collectionSelector or defaultSelector)
    resultSelector = getFunction(resultSelector)    
    result = {}
    for i, item in iterPairs(@)
      start = #result
      sequence = collectionSelector(item, i)
      result[iSeq + start] = resultSelector(item, iSeq) for iSeq, item in ipairs sequence
    @@(result)

  sequenceEqual: (second, equalComparer = defaultEqualComparer) =>    
    return false unless @length == second.length
    equalComparer = getFunction(equalComparer)
    getItem1, getItem2 = iter(@), iter(second)
    for i = 1, @length
      return false unless equalComparer(getItem1!, getItem2!)
    true

  single: (predicate = defaultPredicate) =>
    predicate = getFunction(predicate)
    result = [item for item in iter(@) when predicate(item)]
    assert #result != 0, 'collection is empty'
    assert #result == 1, 'collection has multiple values'
    result[1]

  singleOrDefault: (default, predicate = defaultPredicate) =>
    predicate = getFunction(predicate)  
    result = [item for item in iter(@) when predicate(item)]
    return default if #result == 0
    assert #result == 1, 'collection has multiple values'
    result[1]

  skip: (count) => @@[item for i,item in iterPairs(@) when i > count]

  skipLast: (count) =>  
    result, getItem = {}, iter(@)
    result[i] = getItem! for i = 1, @length - count      
    @@(result)

  --Go through the list in a single iteration.
  skipWhile: (predicate) =>
    predicate = getFunction(predicate)
    result, getItem = {}, iter(@)
    for i = 1, @length
      item = getItem!
      unless predicate(item)
        result[1] = item
        result[j] = getItem! for j = 2, @length - i + 1          
        break
    @@(result)

  sum: (selector = defaultSelector) =>
    selector = getFunction(selector)
    sum = 0
    sum += selector(item) for item in iter(@)
    sum

  take: (count) =>
    result = {}
    for i,item in iterPairs(@)
      if i > count then break else result[i] = item
    @@(result)

  takeLast: (count) => @@[item for i,item in iterPairs(@) when i > @length - count]

  takeWhile: (predicate) =>
    predicate = getFunction(predicate)
    result = {}
    for i,item in iterPairs(@)
      if predicate(item) then result[i] = item else break
    @@(result)

  thenBy: (keySelector = defaultSelector, comparer = defaultComparer) =>
    keySelector = getFunction(keySelector)
    comparer = getFunction(comparer)
    assert @orderedBy > 0, 'not implemented'
    @@(sortAndGroup(@items, @orderedBy, keySelector, comparer), @length, @orderedBy + 1)

  thenByDescending: (keySelector = defaultSelector, comparer = defaultComparer) =>
    keySelector = getFunction(keySelector)
    comparer = getFunction(comparer)
    assert @orderedBy > 0, 'not implemented'
    @@(sortAndGroup(@items, @orderedBy, keySelector, comparer, true), @length, @orderedBy + 1)

  toArray: => [item for item in iter(@)]  

  toDictionary: (keySelector, valueSelector = defaultSelector) =>
    keySelector = getFunction(keySelector)
    valueSelector = getFunction(valueSelector)
    result = {}
    for item in iter(@)
      k = keySelector(item)
      assert result[k] == nil, 'invalid or duplicate key'
      result[k] = valueSelector(item)
    result

  toEnumerable: => @@[item for item in iter(@)]

  toHashSet: =>
    result = {}
    for item in iter(@)
      assert not result[item], 'duplicate key'
      result[item] = true
    result

  toList: => @toArray!

  toLookup: (keySelector, valueSelector = defaultSelector) =>
    keySelector = getFunction(keySelector)
    valueSelector = getFunction(valueSelector)
    result = {}
    for item in iter(@) 
      k = keySelector(item)
      if result[k] == nil then result[k] = {}
      result[k][#result[k] + 1] = valueSelector(item)
    result

  union: (second, equalComparer = defaultEqualComparer) =>
    equalComparer = getFunction(equalComparer)
    result = {}
    index = 1
    for item in iter(@)
      duplicate = false
      for saved in *result
        if equalComparer(item, saved)
          duplicate = true 
          break
      unless duplicate
        result[index] = item 
        index += 1
    for item in iter(second)
      duplicate = false
      for saved in *result
        if equalComparer(item, saved)
          duplicate = true 
          break
      unless duplicate
        result[index] = item 
        index += 1
    @@(result)

  where: (predicate) => 
    predicate = getFunction(predicate)
    @@[item for item in iter(@) when predicate(item)]

  --two collections
  zip: (second, resultSelector = defaultResultSelector) =>
    resultSelector = getFunction(resultSelector)      
    return {} if length == 0
    length = math.min @length, second.length
    result, getItem1, getItem2 = {}, iter(@), iter(second)
    for i = 1, length
      result[i] = resultSelector(getItem1!, getItem2!)
    @@(result)


  -- Utilities
  --------------

  -- single-level tree traversal of table t at level 'depth'
  enumerate = (t, depth) ->
    if depth == 0
      i = 0
      ->
        i += 1
        t[i]
    else
      d = depth - 1
      i = 1
      myIter = enumerate(t[i], d)
      ->
        nextval = myIter!       
        return nextval unless nextval == nil
        i += 1
        if t[i] == nil then return nil
        myIter = enumerate(t[i], d)
        myIter!

  enumeratePairs = (t, depth) ->
    i = 0
    getItem = enumerate(t, depth)
    ->
      i += 1
      item = getItem!
      return nil if item == nil 
      i, item

  sortAndGroup = (t, depth, keySelector, comparer, descending) ->
    if depth > 0    --we need to go deeper
      return [sortAndGroup(t[i], depth - 1, keySelector, comparer, descending) for i = 1, #t]    
    itemKeyPairs = [{item, keySelector(item)} for item in *t]
    sortedIKPs = hybridSort(itemKeyPairs, valueComparerFactory(comparer, descending))
    groupItemsByKey(sortedIKPs, comparer)

  groupItemsByKey = (sortedItemPairs, comparer) ->
    result, r = {{sortedItemPairs[1][1]}}, 1
    for i = 2, #sortedItemPairs
      if comparer(sortedItemPairs[i][2], sortedItemPairs[i - 1][2]) == 0
        result[r][#result[r] + 1] = sortedItemPairs[i][1]
      else
        r += 1
        result[r] = {sortedItemPairs[i][1]}
    result

  ---Given a comparer that takes A and B, create a new function that 
  -- compares only the value of a key-value pair
  valueComparerFactory = (comparer, descending) ->
    (a,b) ->
      valueA, valueB = a[2], b[2]
      if descending then -comparer(valueA, valueB) else comparer(valueA, valueB)

  --- Hybrid merge sort using insertion sort for small collections
  --  naive but stable, unlike lua's quicksort-based `table.sort`
  hybridSort = (list, comparer) ->
    return list unless #list > 1
    return insertionSort(list, comparer) unless #list > 15 --HACK: is 15 a reasonable cutoff?
    midPt = math.floor #list / 2
    left = hybridSort([item for item in *list[,midPt]], comparer)
    right = hybridSort([item for item in *list[midPt + 1,]], comparer)
    return [item for item in merge(left, right, comparer)] if comparer(left[#left], right[1]) > 0
    leftCount = #left
    left[leftCount + i] = item for i,item in ipairs right
    left

  ---Naive insertion sort
  insertionSort = (list, comparer) ->
    for i = 2, #list
      w = list[i] 
      j = i - 1
      while j > 0 and comparer(list[j], w) > 0
        list[j + 1] = list[j]   
        j -= 1
      list[j + 1] = w 
    list  
      
  --- Merge iterator for hybridSort
  --  on each iteration, returns the smallest remaining member from two ascending lists
  --  returns nil when all members are exhausted, terminating the iterator
  merge = (left, right, comparer) ->
    l, r = 1, 1
    ->
      if right[r] == nil or left[l] != nil and comparer(left[l], right[r]) < 1
        l += 1
        return left[l - 1]
      else
        r += 1
        return right[r - 1]

  load = _G.loadstring or _G.load  --for compatibility with lua 5.1

  --- Transform a string lambda into a function
  stringLambda = (str) ->
    arrowStart = assert string.find(str, '->'), 'Invalid string lambda: "'..str..'"'
    argStr = string.sub(str, 1, arrowStart - 1) --arguments come before the arrow
    argStr = string.gsub(string.gsub(argStr, '%(', ''), '%)', '') --remove parentheses
    exprStr = string.sub(str, arrowStart + 2) --expression comes after the arrow
    assert load('return function('..argStr..') return '..exprStr..' end')!

  --- Accept either a function or a string lambda, and return a function.
  -- this might need to have the local _ENV passed in, to reference other functions
  getFunction = (expression) ->
    predType = type(expression)
    return expression if predType == 'function'
    assert predType == 'string', 'Invalid predicate type: ['..predType..']'
    stringLambda(expression)

Enumerable