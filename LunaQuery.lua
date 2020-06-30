local Enumerable
do
  local _class_0
  local defaultSelector, defaultPredicate, defaultEqualComparer, defaultResultSelector, defaultComparer, iter, iterPairs, enumerate, enumeratePairs, sortAndGroup, groupItemsByKey, valueComparerFactory, hybridSort, insertionSort, merge
  local _base_0 = {
    aggregate = function(self, accumulator, initialValue)
      local result = initialValue
      for item in iter(self) do
        result = accumulator(result, item)
      end
      return result
    end,
    all = function(self, predicate)
      for item in iter(self) do
        if not predicate(item) then
          return false
        end
      end
      return true
    end,
    any = function(self, predicate)
      if predicate == nil then
        predicate = defaultPredicate
      end
      for item in iter(self) do
        if predicate(item) then
          return true
        end
      end
      return false
    end,
    append = function(self, element)
      local result = self:toArray()
      result[#result + 1] = element
      return self.__class(result)
    end,
    average = function(self, selector)
      if selector == nil then
        selector = defaultSelector
      end
      local sum, count = 0, 0
      for item in iter(self) do
        sum = sum + selector(item)
        count = count + 1
      end
      if count == 0 then
        return 0
      end
      return sum / count
    end,
    concat = function(self, second)
      local result = self:toArray()
      local itemCount = #result
      for i, item in iterPairs(second) do
        result[i + itemCount] = item
      end
      return self.__class(result)
    end,
    contains = function(self, value, equalComparer)
      if equalComparer == nil then
        equalComparer = defaultEqualComparer
      end
      for item in iter(self) do
        if equalComparer(value, item) then
          return true
        end
      end
      return false
    end,
    count = function(self, predicate)
      if predicate == nil then
        predicate = defaultPredicate
      end
      local sum = 0
      for item in iter(self) do
        if predicate(item) then
          sum = sum + 1
        end
      end
      return sum
    end,
    defaultIfEmpty = function(self, default)
      if iter(self)() == nil then
        return self.__class({
          default
        })
      else
        return self.__class(self.items)
      end
    end,
    distinct = function(self, equalComparer)
      if equalComparer == nil then
        equalComparer = defaultEqualComparer
      end
      local result = { }
      local index = 1
      for item in iter(self) do
        local duplicate = false
        for _index_0 = 1, #result do
          local saved = result[_index_0]
          if equalComparer(item, saved) then
            duplicate = true
          end
        end
        if not (duplicate) then
          result[index] = item
          index = index + 1
        end
      end
      return self.__class(result)
    end,
    elementAt = function(self, index)
      for i, item in iterPairs(self) do
        if i == index then
          return item
        end
      end
      return assert(false, 'No element at the given index')
    end,
    elementAtOrDefault = function(self, index, default)
      for i, item in iterPairs(self) do
        if i == index then
          return item
        end
      end
      return default
    end,
    empty = function(self)
      return self.__class({ })
    end,
    except = function(self, second, equalComparer)
      if equalComparer == nil then
        equalComparer = defaultEqualComparer
      end
      local result, i = { }, 1
      for item in iter(self) do
        local _continue_0 = false
        repeat
          local duplicate = false
          for _index_0 = 1, #result do
            local saved = result[_index_0]
            if equalComparer(item, saved) then
              duplicate = true
              break
            end
          end
          if not (duplicate) then
            for other in iter(second) do
              if equalComparer(item, other) then
                duplicate = true
                break
              end
            end
          end
          if duplicate then
            _continue_0 = true
            break
          end
          result[i] = item
          i = i + 1
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      return self.__class(result)
    end,
    first = function(self, predicate)
      if predicate == nil then
        predicate = defaultPredicate
      end
      for item in iter(self) do
        if predicate(item) then
          return item
        end
      end
      return assert(false, 'No item matches the predicate')
    end,
    firstOrDefault = function(self, default, predicate)
      if predicate == nil then
        predicate = defaultPredicate
      end
      for item in iter(self) do
        if predicate(item) then
          return item
        end
      end
      return default
    end,
    forEach = function(self, action)
      for item in iter(self) do
        action(item)
      end
    end,
    fromDictionary = function(self, table)
      return self.__class((function()
        local _accum_0 = { }
        local _len_0 = 1
        for k, v in pairs(table) do
          _accum_0[_len_0] = {
            k,
            v
          }
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)())
    end,
    fromHashSet = function(self, table)
      return self.__class((function()
        local _accum_0 = { }
        local _len_0 = 1
        for k, v in pairs(table) do
          _accum_0[_len_0] = k
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)())
    end,
    fromList = function(self, table)
      return self.__class((function()
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #table do
          local item = table[_index_0]
          _accum_0[_len_0] = item
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)())
    end,
    groupBy = function(self, keySelector, valueSelector, resultSelector, equalComparer)
      if valueSelector == nil then
        valueSelector = defaultSelector
      end
      if resultSelector == nil then
        resultSelector = defaultResultSelector
      end
      if equalComparer == nil then
        equalComparer = defaultEqualComparer
      end
      local result = { }
      for item in iter(self) do
        local key = keySelector(item)
        local duplicateKey = false
        for i, existingKVs in ipairs(result) do
          local existingKey = existingKVs[1]
          if equalComparer(existingKey, key) then
            duplicateKey = true
            local existingValues = result[i][2]
            existingValues[#existingValues + 1] = valueSelector(item)
            break
          end
        end
        if not (duplicateKey) then
          result[#result + 1] = {
            key,
            {
              valueSelector(item)
            }
          }
        end
      end
      return self.__class((function()
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #result do
          local kv = result[_index_0]
          _accum_0[_len_0] = resultSelector(kv[1], kv[2])
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)())
    end,
    groupJoin = function(self, inner, outerSelector, innerSelector, resultSelector, equalComparer)
      if equalComparer == nil then
        equalComparer = defaultEqualComparer
      end
      local keyedInner
      do
        local _accum_0 = { }
        local _len_0 = 1
        for item in iter(inner) do
          _accum_0[_len_0] = {
            innerSelector(item),
            item
          }
          _len_0 = _len_0 + 1
        end
        keyedInner = _accum_0
      end
      local result = { }
      for i, oItem in iterPairs(self) do
        local outerKey = outerSelector(oItem)
        local group, groupIndex = { }, 1
        for _index_0 = 1, #keyedInner do
          local iKeyVal = keyedInner[_index_0]
          local innerKey, innerItem = iKeyVal[1], iKeyVal[2]
          if equalComparer(outerKey, innerKey) then
            group[groupIndex] = innerItem
            groupIndex = groupIndex + 1
          end
        end
        result[i] = resultSelector(oItem, group)
      end
      return self.__class(result)
    end,
    intersect = function(self, second, equalComparer)
      if equalComparer == nil then
        equalComparer = defaultEqualComparer
      end
      local result = { }
      for item in iter(self) do
        local _continue_0 = false
        repeat
          local isUnique = true
          local intersects = false
          for _index_0 = 1, #result do
            local saved = result[_index_0]
            if equalComparer(item, saved) then
              isUnique = false
              break
            end
          end
          if not (isUnique) then
            _continue_0 = true
            break
          end
          for other in iter(second) do
            if equalComparer(item, other) then
              intersects = true
              break
            end
          end
          if isUnique and intersects then
            result[#result + 1] = item
          end
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      return self.__class(result)
    end,
    join = function(self, inner, outerSelector, innerSelector, resultSelector, equalComparer)
      if equalComparer == nil then
        equalComparer = defaultEqualComparer
      end
      local keyedInner
      do
        local _accum_0 = { }
        local _len_0 = 1
        for item in iter(inner) do
          _accum_0[_len_0] = {
            innerSelector(item),
            item
          }
          _len_0 = _len_0 + 1
        end
        keyedInner = _accum_0
      end
      local iResult, result = 1, { }
      for item in iter(self) do
        for _index_0 = 1, #keyedInner do
          local iKeyVal = keyedInner[_index_0]
          local ikey, iItem = iKeyVal[1], iKeyVal[2]
          if equalComparer(outerSelector(item), ikey) then
            result[iResult] = resultSelector(item, iItem)
            iResult = iResult + 1
          end
        end
      end
      return self.__class(result)
    end,
    last = function(self, predicate)
      if predicate == nil then
        predicate = defaultPredicate
      end
      local result = nil
      for item in iter(self) do
        if predicate(item) then
          result = item
        end
      end
      if not (result == nil) then
        return result
      end
      return assert(false, 'No item matches the predicate')
    end,
    lastOrDefault = function(self, default, predicate)
      if predicate == nil then
        predicate = defaultPredicate
      end
      local result = default
      for item in iter(self) do
        if predicate(item) then
          result = item
        end
      end
      return result
    end,
    max = function(self, selector)
      if selector == nil then
        selector = defaultSelector
      end
      local getItem = iter(self)
      local result = selector(getItem())
      for i = 2, self.length do
        local sVal = selector(getItem())
        if sVal > result then
          result = sVal
        end
      end
      return result
    end,
    min = function(self, selector)
      if selector == nil then
        selector = defaultSelector
      end
      local getItem = iter(self)
      local result = selector(getItem())
      for i = 2, self.length do
        local sVal = selector(getItem())
        if sVal < result then
          result = sVal
        end
      end
      return result
    end,
    ofType = function(self, whichType)
      return self.__class((function()
        local _accum_0 = { }
        local _len_0 = 1
        for item in iter(self) do
          if type(item) == whichType then
            _accum_0[_len_0] = item
            _len_0 = _len_0 + 1
          end
        end
        return _accum_0
      end)())
    end,
    orderBy = function(self, keySelector, comparer)
      if keySelector == nil then
        keySelector = defaultSelector
      end
      if comparer == nil then
        comparer = defaultComparer
      end
      return self.__class(sortAndGroup((function()
        local _accum_0 = { }
        local _len_0 = 1
        for item in iter(self) do
          _accum_0[_len_0] = item
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)(), 0, keySelector, comparer), self.length, 1)
    end,
    orderByDescending = function(self, keySelector, comparer)
      if keySelector == nil then
        keySelector = defaultSelector
      end
      if comparer == nil then
        comparer = defaultComparer
      end
      return self.__class(sortAndGroup((function()
        local _accum_0 = { }
        local _len_0 = 1
        for item in iter(self) do
          _accum_0[_len_0] = item
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)(), 0, keySelector, comparer, true), self.length, 1)
    end,
    prepend = function(self, element)
      local result = {
        element
      }
      for i, item in iterPairs(self) do
        result[i + 1] = item
      end
      return self.__class(result)
    end,
    range = function(self, start, count)
      return self.__class((function()
        local _accum_0 = { }
        local _len_0 = 1
        for i = start, start + count - 1 do
          _accum_0[_len_0] = i
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)())
    end,
    repeatElement = function(self, element, count)
      return self.__class((function()
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, count do
          _accum_0[_len_0] = element
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)())
    end,
    reverse = function(self)
      local result, r = { }, self.length + 1
      for i, item in iterPairs(self) do
        result[r - i] = item
      end
      return self.__class(result)
    end,
    select = function(self, selector)
      return self.__class((function()
        local _accum_0 = { }
        local _len_0 = 1
        for i, item in iterPairs(self) do
          _accum_0[_len_0] = selector(item, i)
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)())
    end,
    selectMany = function(self, collectionSelector, resultSelector)
      if resultSelector == nil then
        resultSelector = defaultSelector
      end
      collectionSelector = collectionSelector or defaultSelector
      local result = { }
      for i, item in iterPairs(self) do
        local start = #result
        local sequence = collectionSelector(item, i)
        for iSeq, item in ipairs(sequence) do
          result[iSeq + start] = resultSelector(item, iSeq)
        end
      end
      return self.__class(result)
    end,
    sequenceEqual = function(self, second, equalComparer)
      if equalComparer == nil then
        equalComparer = defaultEqualComparer
      end
      if not (self.length == second.length) then
        return false
      end
      local getItem1, getItem2 = iter(self), iter(second)
      for i = 1, self.length do
        if not (equalComparer(getItem1(), getItem2())) then
          return false
        end
      end
      return true
    end,
    single = function(self, predicate)
      if predicate == nil then
        predicate = defaultPredicate
      end
      local result
      do
        local _accum_0 = { }
        local _len_0 = 1
        for item in iter(self) do
          if predicate(item) then
            _accum_0[_len_0] = item
            _len_0 = _len_0 + 1
          end
        end
        result = _accum_0
      end
      assert(#result ~= 0, 'collection is empty')
      assert(#result == 1, 'collection has multiple values')
      return result[1]
    end,
    singleOrDefault = function(self, default, predicate)
      if predicate == nil then
        predicate = defaultPredicate
      end
      local result
      do
        local _accum_0 = { }
        local _len_0 = 1
        for item in iter(self) do
          if predicate(item) then
            _accum_0[_len_0] = item
            _len_0 = _len_0 + 1
          end
        end
        result = _accum_0
      end
      if #result == 0 then
        return default
      end
      assert(#result == 1, 'collection has multiple values')
      return result[1]
    end,
    skip = function(self, count)
      return self.__class((function()
        local _accum_0 = { }
        local _len_0 = 1
        for i, item in iterPairs(self) do
          if i > count then
            _accum_0[_len_0] = item
            _len_0 = _len_0 + 1
          end
        end
        return _accum_0
      end)())
    end,
    skipLast = function(self, count)
      local result, getItem = { }, iter(self)
      for i = 1, self.length - count do
        result[i] = getItem()
      end
      return self.__class(result)
    end,
    skipWhile = function(self, predicate)
      local result, getItem = { }, iter(self)
      for i = 1, self.length do
        local item = getItem()
        if not (predicate(item)) then
          result[1] = item
          for j = 2, self.length - i + 1 do
            result[j] = getItem()
          end
          break
        end
      end
      return self.__class(result)
    end,
    sum = function(self, selector)
      if selector == nil then
        selector = defaultSelector
      end
      local sum = 0
      for item in iter(self) do
        sum = sum + selector(item)
      end
      return sum
    end,
    take = function(self, count)
      local result = { }
      for i, item in iterPairs(self) do
        if i > count then
          break
        else
          result[i] = item
        end
      end
      return self.__class(result)
    end,
    takeLast = function(self, count)
      return self.__class((function()
        local _accum_0 = { }
        local _len_0 = 1
        for i, item in iterPairs(self) do
          if i > self.length - count then
            _accum_0[_len_0] = item
            _len_0 = _len_0 + 1
          end
        end
        return _accum_0
      end)())
    end,
    takeWhile = function(self, predicate)
      local result = { }
      for i, item in iterPairs(self) do
        if predicate(item) then
          result[i] = item
        else
          break
        end
      end
      return self.__class(result)
    end,
    thenBy = function(self, keySelector, comparer)
      if keySelector == nil then
        keySelector = defaultSelector
      end
      if comparer == nil then
        comparer = defaultComparer
      end
      assert(self.orderedBy > 0, 'not implemented')
      return self.__class(sortAndGroup(self.items, self.orderedBy, keySelector, comparer), self.length, self.orderedBy + 1)
    end,
    thenByDescending = function(self, keySelector, comparer)
      if keySelector == nil then
        keySelector = defaultSelector
      end
      if comparer == nil then
        comparer = defaultComparer
      end
      assert(self.orderedBy > 0, 'not implemented')
      return self.__class(sortAndGroup(self.items, self.orderedBy, keySelector, comparer, true), self.length, self.orderedBy + 1)
    end,
    toArray = function(self)
      local _accum_0 = { }
      local _len_0 = 1
      for item in iter(self) do
        _accum_0[_len_0] = item
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end,
    toDictionary = function(self, keySelector, valueSelector)
      if valueSelector == nil then
        valueSelector = defaultSelector
      end
      local result = { }
      for item in iter(self) do
        local k = keySelector(item)
        assert(result[k] == nil, 'invalid or duplicate key')
        result[k] = valueSelector(item)
      end
      return result
    end,
    toEnumerable = function(self)
      return self.__class((function()
        local _accum_0 = { }
        local _len_0 = 1
        for item in iter(self) do
          _accum_0[_len_0] = item
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)())
    end,
    toHashSet = function(self)
      local result = { }
      for item in iter(self) do
        assert(not result[item], 'duplicate key')
        result[item] = true
      end
      return result
    end,
    toList = function(self)
      return self:toArray()
    end,
    toLookup = function(self, keySelector, valueSelector)
      if valueSelector == nil then
        valueSelector = defaultSelector
      end
      local result = { }
      for item in iter(self) do
        local k = keySelector(item)
        if result[k] == nil then
          result[k] = { }
        end
        result[k][#result[k] + 1] = valueSelector(item)
      end
      return result
    end,
    union = function(self, second, equalComparer)
      if equalComparer == nil then
        equalComparer = defaultEqualComparer
      end
      local result = { }
      local index = 1
      for item in iter(self) do
        local duplicate = false
        for _index_0 = 1, #result do
          local saved = result[_index_0]
          if equalComparer(item, saved) then
            duplicate = true
            break
          end
        end
        if not (duplicate) then
          result[index] = item
          index = index + 1
        end
      end
      for item in iter(second) do
        local duplicate = false
        for _index_0 = 1, #result do
          local saved = result[_index_0]
          if equalComparer(item, saved) then
            duplicate = true
            break
          end
        end
        if not (duplicate) then
          result[index] = item
          index = index + 1
        end
      end
      return self.__class(result)
    end,
    where = function(self, predicate)
      return self.__class((function()
        local _accum_0 = { }
        local _len_0 = 1
        for item in iter(self) do
          if predicate(item) then
            _accum_0[_len_0] = item
            _len_0 = _len_0 + 1
          end
        end
        return _accum_0
      end)())
    end,
    zip = function(self, second, resultSelector)
      if resultSelector == nil then
        resultSelector = defaultResultSelector
      end
      if length == 0 then
        return { }
      end
      local length = math.min(self.length, second.length)
      local result, getItem1, getItem2 = { }, iter(self), iter(second)
      for i = 1, length do
        result[i] = resultSelector(getItem1(), getItem2())
      end
      return self.__class(result)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, collection, count, orderedBy)
      self.items = collection
      self.length = count or #collection
      self.orderedBy = orderedBy or 0
    end,
    __base = _base_0,
    __name = "Enumerable"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  defaultSelector = function(a)
    return a
  end
  defaultPredicate = function(a)
    return true
  end
  defaultEqualComparer = function(a, b)
    return a == b
  end
  defaultResultSelector = function(a, b)
    return {
      a,
      b
    }
  end
  defaultComparer = function(a, b)
    if a > b then
      return 1
    else
      if a < b then
        return -1
      else
        return 0
      end
    end
  end
  iter = function(self)
    return enumerate(self.items, self.orderedBy)
  end
  iterPairs = function(self)
    return enumeratePairs(self.items, self.orderedBy)
  end
  enumerate = function(t, depth)
    if depth == 0 then
      local i = 0
      return function()
        i = i + 1
        return t[i]
      end
    else
      local d = depth - 1
      local i = 1
      local myIter = enumerate(t[i], d)
      return function()
        local nextval = myIter()
        if not (nextval == nil) then
          return nextval
        end
        i = i + 1
        if t[i] == nil then
          return nil
        end
        myIter = enumerate(t[i], d)
        return myIter()
      end
    end
  end
  enumeratePairs = function(t, depth)
    local i = 0
    local getItem = enumerate(t, depth)
    return function()
      i = i + 1
      local item = getItem()
      if item == nil then
        return nil
      end
      return i, item
    end
  end
  sortAndGroup = function(t, depth, keySelector, comparer, descending)
    if depth > 0 then
      local _accum_0 = { }
      local _len_0 = 1
      for i = 1, #t do
        _accum_0[_len_0] = sortAndGroup(t[i], depth - 1, keySelector, comparer, descending)
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end
    local itemKeyPairs
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #t do
        local item = t[_index_0]
        _accum_0[_len_0] = {
          item,
          keySelector(item)
        }
        _len_0 = _len_0 + 1
      end
      itemKeyPairs = _accum_0
    end
    local sortedIKPs = hybridSort(itemKeyPairs, valueComparerFactory(comparer, descending))
    return groupItemsByKey(sortedIKPs, comparer)
  end
  groupItemsByKey = function(sortedItemPairs, comparer)
    local result, r = {
      {
        sortedItemPairs[1][1]
      }
    }, 1
    for i = 2, #sortedItemPairs do
      if comparer(sortedItemPairs[i][2], sortedItemPairs[i - 1][2]) == 0 then
        result[r][#result[r] + 1] = sortedItemPairs[i][1]
      else
        r = r + 1
        result[r] = {
          sortedItemPairs[i][1]
        }
      end
    end
    return result
  end
  valueComparerFactory = function(comparer, descending)
    return function(a, b)
      local valueA, valueB = a[2], b[2]
      if descending then
        return -comparer(valueA, valueB)
      else
        return comparer(valueA, valueB)
      end
    end
  end
  hybridSort = function(list, comparer)
    if not (#list > 1) then
      return list
    end
    if not (#list > 15) then
      return insertionSort(list, comparer)
    end
    local midPt = math.floor(#list / 2)
    local left = hybridSort((function()
      local _accum_0 = { }
      local _len_0 = 1
      local _max_0 = midPt
      for _index_0 = 1, _max_0 < 0 and #list + _max_0 or _max_0 do
        local item = list[_index_0]
        _accum_0[_len_0] = item
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)(), comparer)
    local right = hybridSort((function()
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = midPt + 1, #list do
        local item = list[_index_0]
        _accum_0[_len_0] = item
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)(), comparer)
    if comparer(left[#left], right[1]) > 0 then
      local _accum_0 = { }
      local _len_0 = 1
      for item in merge(left, right, comparer) do
        _accum_0[_len_0] = item
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end
    local leftCount = #left
    for i, item in ipairs(right) do
      left[leftCount + i] = item
    end
    return left
  end
  insertionSort = function(list, comparer)
    for i = 2, #list do
      local w = list[i]
      local j = i - 1
      while j > 0 and comparer(list[j], w) > 0 do
        list[j + 1] = list[j]
        j = j - 1
      end
      list[j + 1] = w
    end
    return list
  end
  merge = function(left, right, comparer)
    local l, r = 1, 1
    return function()
      if right[r] == nil or left[l] ~= nil and comparer(left[l], right[r]) < 1 then
        l = l + 1
        return left[l - 1]
      else
        r = r + 1
        return right[r - 1]
      end
    end
  end
  Enumerable = _class_0
end
return Enumerable
