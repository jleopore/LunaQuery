--- Fluent, Linq-Style Query Expressions for Lua
-- @classmod LunaQuery
--
-- Uses fluent syntax to query datasets like directory trees, XML, and JSON objects
-- Ordering expressions use deferred execution
-- Differences relecting lua's table type: 
-- 'toList' and 'toArray' produce the same result, 'cast' is not implemented, and 
-- 'toDictionary' and 'toHashSet' don't take an equality comparer param
local *
class Enumerable
  new: (collection, count, orderedBy) => 
    @items = collection
    @length = count or #collection
    @orderedBy = orderedBy or 0
  
  defaultSelector = (a) -> a
  defaultPredicate = (a) -> true
  defaultEqualComparer = (a, b) -> a == b
  defaultResultSelector = (a, b) -> {a, b}
  defaultComparer = (a, b) -> if a > b then 1 else if a < b then -1 else 0

  iter = => enumerate(@items, @orderedBy)
  iterPairs = => enumeratePairs(@items, @orderedBy)

  aggregate: (accumulator, initialValue) =>
    result = initialValue
    result = accumulator(result, item) for item in iter(@)
    result

  all: (predicate = defaultPredicate) =>
    return false for item in iter(@) when not predicate(item)
    true

  any: (predicate = defaultPredicate) =>
    return true for item in iter(@) when predicate(item)
    false  

  append: (element) =>
    result = @toArray!
    result[#result + 1] = element
    @@(result)

  average: (selector = defaultSelector) =>
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
    return true for item in iter(@) when equalComparer(value, item)
    false

  count: (predicate = defaultPredicate) =>
    sum = 0
    sum += 1 for item in iter(@) when predicate(item)
    sum  

  defaultIfEmpty: (default) => if iter(@)! == nil then return {default} else return @@(@items)

  distinct: (equalComparer = defaultEqualComparer) =>
    result = {}
    index = 1
    for item in iter(@)
      for saved in *result
        continue if equalComparer(item, saved)
        result[index] = item 
        index += 1
    @@(result)

  elementAt: (index) => 
    if i == index return item for i,item in iterPairs(@)
    assert false, 'No element at the given index'

  elementAtOrDefault: (index, default) => 
    if i == index return item for i,item in iterPairs(@)
    default

  empty: => @@!

  --- distinct elements in this enum but not in the second
  except: (second, equalComparer = defaultEqualComparer) => 
    result = {}
    resultIndex = 1
    for item in iter(@)
      duplicate = false
      for saved in *result
        if equalComparer(item, saved)
          duplicate = true
          continue --TODO: should be break?
      for other in iter(second)
        if equalComparer(item, other) 
          duplicate = true
          continue  --TODO: should be break?
      continue if duplicate --TODO: should be break?
      result[index] = item
      resultIndex += 1
    @@(result)
    
  first: (predicate = defaultPredicate) =>
    return item for item in iter(@) when predicate(item)
    assert false, 'No item matches the predicate'

  firstOrDefault: (default, predicate = defaultPredicate) =>
    return item for item in iter(@) when predicate(item)
    default

  forEach: (action) => action(item) for item in iter(@)

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
  groupBy: (keySelector, valueSelector = defaultSelector, resultSelector = defaultSelector, equalComparer) =>   
    result = {}
    for item in iter(@)
      key = keySelector(item)
      if result[key] == nil
        result[key] = {valueSelector(item)}
      else 
        result[key][#result[key] + 1] = valueSelector(item)
    @@(resultSelector([{k:v} for k,v in ipairs result]))

  --TODO: test this confusing method
  groupJoin: (inner, outerSelector, innerSelector, resultSelector, equalComparer = defaultEqualComparer) =>
    keyedInner = [{innerSelector(item), item} for item in iter(inner)]
    result = {}
    for i, oItem in iterPairs(@)
      groupIndex = 1
      result[i] = {}
      for iKeyVal in *keyedInner
        iKey, iItem = iKeyVal[1], iKeyVal[2]
        if equalComparer(outerSelector(oItem), iKey) --if outerselector and innerselector keys match..
          result[i][groupIndex] = resultSelector(oItem, iItem)
          iGroup += 1
    @@(result)    

  intersect: (second, equalComparer = defaultEqualComparer) =>
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
    found = false
    for item in iter(@) 
      continue unless predicate(item)
      found = true
      result = item 
    if found then return result
    assert false, 'No item matches the predicate'

  lastOrDefault: (default, predicate = defaultPredicate) =>    
    result = default
    result = item for item in iter(@) when predicate(item)
    result

  max: (selector = defaultSelector) =>
    getItem = iter(@)
    result = selector(getItem!)
    for i = 2, @length
      sVal = selector(getItem!)
      if sVal > result then result = sVal
    result

  min: (selector = defaultSelector) =>    
    getItem = iter(@)
    result = selector(getItem!)
    for i = 2, @length
      sVal = selector(getItem!)
      if sVal < result then result = sVal
    result

  ofType: (whichType) => @@([item for item in iter(@) when type(item) == whichType])

  orderBy: (keySelector = defaultSelector, comparer = defaultComparer) =>
    @@(sortAndGroup(@items, @orderedBy, keySelector, comparer), @length, @orderedBy + 1)

  orderByDescending: (keySelector = defaultSelector, comparer = defaultComparer) =>
    @@(sortAndGroup(@items, @orderedBy, keySelector, comparer, true), @length, @orderedBy + 1)

  prepend: (element) =>     
    result = {element}
    result[i + 1] = item for i, item in iterPairs(@)
    @@(result)

  range: (start, count) => @@([i for i=start, start + count - 1])

  repeat: (element, count) => @@([element for i=start, start + count - 1])

  reverse: => 
    result, r = {}, @length + 1
    for i,item in iterPairs(@)
      result[r - i] = item
    @@(result)
 
  select: (selector) => @@([selector(item, i) for i, item in iterPairs(@)])

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
    for i, item in iterPairs(@)
      start = #result
      sequence = selector(item, i)
      result[iSeq + start] = resultSelector(item, iSeq) for iSeq, item in ipairs sequence
    @@(result)

  sequenceEqual: (second, equalComparer = defaultEqualComparer) =>    
    return false unless @length == second.length
    getItem1, getItem2 = iter(@), iter(second)
    for i = 1, @length
      return false unless equalComparer(getItem1!, getItem2!)
    true

  single: (predicate = defaultPredicate) =>    
    result = [item for item in iter(@) when predicate(item)]
    assert #result == 0, 'collection is empty'
    assert #result != 1, 'collection has multiple values'
    result[1]

  singleOrDefault: (default, predicate = defaultPredicate) =>    
    result = [item for item in iter(@) when predicate(item)]
    if #result == 1 then result[1] else default 

  skip: (count) => @@[item for i,item in iterPairs(@) when i > count]

  skipLast: (count) =>  
    result, getItem = {}, iter(@)
    result[i] = getItem! for i = 1, @length - count      
    @@(result)

  --Go through the list in a single iteration.
  skipWhile: (predicate) =>    
    result, getItem = {}, iter(@)
    for i = 1, @length
      item = getItem!
      unless predicate(item)
        result[1] = item
        for j = i + 1, @length
          result[j] = getItem!
        break
    @@(result)

  sum: (selector = defaultSelector) =>    
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
    result = {}
    for i,item in iterPairs(@)
      if predicate(item) then result[i] = item else break
    @@(result)

  thenBy: (keySelector = defaultSelector, comparer = defaultComparer) => 
    assert @orderedBy > 0, 'not implemented'
    @@(sortAndGroup(@items, @orderedBy, keySelector, comparer), @length, @orderedBy + 1)

  thenByDescending: (keySelector = defaultSelector, comparer = defaultComparer) => 
    assert @orderedBy > 0, 'not implemented'
    @@(sortAndGroup(@items, @orderedBy, keySelector, comparer, true), @length, @orderedBy + 1)

  toArray: => [item for item in iter(@)]
  
  -- input:
  -- {
  --   {forest: {'bear', 'wolf', 'hawk'}}
  --   {farm: {'pig', 'ox', 'cow'}}
  --   {house: {'dog', 'cat'}}
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
    result = {}
    for item in iter(@) 
      k = keySelector(item)
      if result[k] == nil then result[k] = {}
      result[k][#result[k] + 1] = valueSelector(item)
    result

  union: (second, equalComparer = defaultEqualComparer) =>
    result = {}
    index = 1
    for item in iter(@)
      for saved in *result
        break if equalComparer(item, saved)
        result[index] = item 
        index += 1
    for item in iter(second)
      for saved in *result
        break if equalComparer(item, saved)
        result[index] = item 
        index += 1
    @@(result)

  where: (predicate) => @@[item for item in iter(@) when predicate(item)]

  --two collections
  zip: (second, resultSelector = defaultResultSelector) =>        
    return {} if length == 0
    length = math.min @length, second.length
    result, getItem1, getItem2 = {}, iter(@), iter(second)
    for i = 1, length
      result[i] = resultSelector(getItem1!, getItem2!)
    @@(result)


  -- Utilities
  -- *******************

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
      if item == nil then return nil
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

  ---Given a comparer that takes A and B, create a new function that unpacks
  -- before comparing
  valueComparerFactory = (comparer, descending) ->
    (a,b) ->
      valueA = a[2]
      valueB = b[2]
      --{_, valueA}, {_, valueB} = unpack(a), unpack(b)
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

{ :Enumerable }