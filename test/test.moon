Enumerable = require 'src.LunaQuery'
isSame = (require 'test.util').deepcompare

--Sample Data
---------------
lemonade = Enumerable\fromList({'get', 'your', 'ice', 'cold', 'lemonade', 'here'})
numbers = Enumerable\fromList({1,2,3,10,10,10,100,200,300})
mixed = Enumerable\fromList({1,2,3,'apple', 'fig', 'kiwi'})


--aggregate
assert numbers\aggregate(((a,b) -> a + b), 0) == 636
assert lemonade\aggregate(((a,b) -> a..b), '') == 'getyouricecoldlemonadehere'

--all
assert numbers\all((a) -> type(a) == 'string')   == false
assert numbers\all((a) -> type(a) == 'number')   == true
assert lemonade\all((a) -> type(a) == 'string')  == true
assert lemonade\all((a) -> type(a) == 'number')  == false
assert mixed\all((a) -> type(a) == 'string')     == false
assert mixed\all((a) -> type(a) == 'number')     == false

--any
assert Enumerable\fromList({})\any!                 == false
assert Enumerable\fromList({5, 'cups', 'tea'})\any! == true
assert numbers\any((a) -> type(a) == 'string')      == false
assert numbers\any((a) -> type(a) == 'number')      == true
assert lemonade\any((a) -> type(a) == 'string')     == true
assert lemonade\any((a) -> type(a) == 'number')     == false
assert mixed\any((a) -> type(a) == 'string')        == true
assert mixed\any((a) -> type(a) == 'number')        == true

--append
assert isSame(lemonade\append('extra')\toList!,
  {'get', 'your', 'ice', 'cold', 'lemonade', 'here', 'extra'})
assert isSame(numbers\append(17)\toList!,
  {1,2,3,10,10,10,100,200,300,17})

--average
assert numbers\average! == 636 / 9
assert numbers\average((a) -> a - 1) == (636 - 9) / 9

--concat
assert isSame(numbers\concat(mixed)\toList!, 
  {1,2,3,10,10,10,100,200,300,1,2,3,'apple','fig','kiwi'})

--contains
assert numbers\contains(22)   == false
assert numbers\contains(2)    == true
assert mixed\contains('fish') == false
assert mixed\contains('fig')  == true
assert lemonade\contains('aaaaa', (a,b) -> #a == #b) == false
assert lemonade\contains('aaaa',  (a,b) -> #a == #b) == true

--count
assert numbers\count! == 9
assert numbers\count((a) -> a > 5) == 6

--defaultIfEmpty
tmp = {5, 'cups', 'tea'}
assert isSame(Enumerable\fromList(tmp)\defaultIfEmpty('teacup')\toList!, tmp)
assert isSame(Enumerable\fromList({})\defaultIfEmpty('teacup')\toList!, {'teacup'})

--distinct
assert isSame(Enumerable\fromList({'hello', 'world', 'world'})\distinct!\toList!,
  {'hello', 'world'})
assert isSame(numbers\distinct!\toList!, 
  {1,2,3,10,100,200,300})
assert isSame(numbers\distinct((a,b) -> (a - b) * (a - b) < 25)\toList!,
  {1,10,100,200,300})

--elementAt
assert mixed\elementAt(5) == 'fig'
assert numbers\elementAt(9) == 300

--elementAtOrDefault
assert mixed\elementAtOrDefault(5, 'tea') == 'fig'
assert mixed\elementAtOrDefault(100, 'tea') == 'tea'

--empty
assert isSame(Enumerable\empty!\toList!, {})

--except 
--TODO: test with custom equalsComparer
assert isSame(numbers\except(mixed)\toList!, {10,100,200,300})

--first
assert lemonade\first!                == 'get'
assert lemonade\first((a) -> #a > 4)  == 'lemonade'

--firstOrDefault
assert lemonade\firstOrDefault('tea')                 == 'get'
assert lemonade\firstOrDefault('tea', (a) -> #a > 4)  == 'lemonade'
assert lemonade\firstOrDefault('tea', (a) -> #a > 10) == 'tea'

--forEach
tmp = {}
lemonade\forEach((a) -> tmp[#tmp + 1] = #a)
assert isSame(tmp, {3,4,3,4,8,4})

--fromDictionary
assert Enumerable\fromDictionary({key1: 25, key2: 'potato'})\count! == 2

--fromHashSet
tmp = Enumerable\fromHashSet({peach:true, banana:true, [15]: true})
assert tmp\count! == 3
assert tmp\contains('banana')

--fromList
assert isSame(Enumerable\fromList({5, 'cups', 'tea'})\toList!, {5, 'cups', 'tea'})

--groupBy
assert isSame(lemonade\groupBy((a) -> #a)\toList!,
{
  {3, {'get','ice'}}
  {4, {'your','cold','here'}}
  {8, {'lemonade'}}
})    

--groupJoin
tmp = Enumerable\fromList(
{
  {name:'seal', likes:'ice', hates:'lemonade'},  
  {name:'toad', likes:'sand', hates:'lemonade'},
  {name:'fox', likes:'lemonade', hates:'ice'}
})
assert isSame(lemonade\groupJoin(tmp, ((a) -> a), ((a) -> a.hates), (a,b) -> a..' haters: '..#b)\toList!,
  {
    'get haters: 0',
    'your haters: 0',
    'ice haters: 1',
    'cold haters: 0',
    'lemonade haters: 2',
    'here haters: 0'
  })

--intersect
--TODO: test with custom equalsComparer
assert isSame(numbers\intersect(mixed)\toList!, {1,2,3})

--join
tmp = Enumerable\fromList(
{
  {name:'seal', likes:'ice', hates:'lemonade'},  
  {name:'toad', likes:'sand', hates:'lemonade'},
  {name:'fox', likes:'lemonade', hates:'ice'}
})
assert isSame(tmp\join(lemonade, ((a) -> a.likes), ((a) -> a), (a,b) -> a.name..' is satisfied')\toList!,
  {'seal is satisfied', 'fox is satisfied'})

--last
assert lemonade\last!                == 'here'
assert lemonade\last((a) -> #a < 4)  == 'ice'

--lastOrDefault
assert lemonade\lastOrDefault('tea')                == 'here'
assert lemonade\lastOrDefault('tea', (a) -> #a < 4) == 'ice'
assert lemonade\lastOrDefault('tea', (a) -> #a < 3) == 'tea'

--max
assert lemonade\max! == 'your'
assert numbers\max! == 300
mixedComparer = (a) -> if type(a) == 'string' then #a else a
assert mixed\max(mixedComparer) == 5

--min
assert lemonade\min! == 'cold'
assert numbers\min! == 1
mixedComparer = (a) -> if type(a) == 'string' then #a else 10
assert mixed\min(mixedComparer) == 3

--ofType
assert isSame(lemonade\ofType('number')\toList!, {})
assert isSame(numbers\ofType('number')\toList!, numbers\toList!)
assert isSame(mixed\ofType('number')\toList!, {1,2,3})
assert isSame(lemonade\ofType('string')\toList!, lemonade\toList!)
assert isSame(numbers\ofType('string')\toList!, {})
assert isSame(mixed\ofType('string')\toList!, {'apple', 'fig', 'kiwi'})

--orderBy
--TODO: test with custom comparer
assert isSame(lemonade\orderBy!\toList!,
  {'cold','get','here','ice','lemonade','your'})
assert isSame(lemonade\orderBy((a) -> #a)\toList!,
  {'get','ice','your','cold','here','lemonade'})
assert isSame(numbers\orderBy!\toList!,
  {1,2,3,10,10,10,100,200,300})
assert isSame(numbers\orderBy((a) -> -a)\toList!,
  {300,200,100,10,10,10,3,2,1})
mixedSelector = (a) -> if type(a) == 'string' then #a else 10
assert isSame(mixed\orderBy(mixedSelector)\toList!, {'fig','kiwi','apple',1,2,3})

--orderByDescending
--TODO: test with custom comparer
assert isSame(lemonade\orderByDescending!\toList!,
  {'your','lemonade','ice','here','get','cold'})
assert isSame(lemonade\orderByDescending((a) -> #a)\toList!,
  {'lemonade','your','cold','here','get','ice'})
assert isSame(numbers\orderByDescending!\toList!,
  {300,200,100,10,10,10,3,2,1})
assert isSame(numbers\orderByDescending((a) -> -a)\toList!,
  {1,2,3,10,10,10,100,200,300})
mixedSelector = (a) -> if type(a) == 'string' then #a else 10
assert isSame(mixed\orderByDescending(mixedSelector)\toList!, {1,2,3,'apple','kiwi','fig'})

--prepend
assert isSame(lemonade\prepend('extra')\toList!,
  {'extra','get','your','ice','cold','lemonade','here'})
assert isSame(numbers\prepend(17)\toList!,
  {17,1,2,3,10,10,10,100,200,300})

--range
assert isSame(Enumerable\range(0,5)\toList!, {0,1,2,3,4})
assert isSame(Enumerable\range(-3,5)\toList!, {-3,-2,-1,0,1})

--repeatElement
assert isSame(Enumerable\repeatElement(0,5)\toList!, {0,0,0,0,0})
assert isSame(Enumerable\repeatElement(-3,5)\toList!, {-3,-3,-3,-3,-3})
assert isSame(Enumerable\repeatElement('i',5)\toList!, {'i','i','i','i','i'})

--reverse
assert isSame(lemonade\reverse!\toList!,
  {'here','lemonade','cold','ice','your','get'})
assert isSame(numbers\reverse!\toList!,
  {300,200,100,10,10,10,3,2,1})

--select
assert isSame(lemonade\select((a) -> #a)\toList!, {3,4,3,4,8,4})
assert isSame(lemonade\select((a, i) -> #a + i)\toList!, {4,6,6,8,13,10})

--selectMany
tmp = Enumerable\fromList(
  {
    {'dog', 'cow', 'bear'},
    {'fish'},
    {'mouse', 'buffalo'}
  })
assert isSame(tmp\selectMany!\toList!, 
  {'dog', 'cow', 'bear', 'fish', 'mouse', 'buffalo'})
assert isSame(tmp\selectMany(((a) -> a), (a) -> #a)\toList!, 
  {3,3,4,4,5,7})
assert isSame(tmp\selectMany(nil, (a) -> #a)\toList!, 
  {3,3,4,4,5,7})
assert isSame(tmp\selectMany((a) -> {a[1]})\toList!, 
  {'dog','fish','mouse'})
assert isSame(tmp\selectMany(((a) -> {a[1]}), (a) -> #a)\toList!, 
  {3,4,5})

--sequenceEqual
tmp = Enumerable\fromList({'duck', 'duck','goose'})
isSameType = (a,b) -> type(a) == type(b)
assert tmp\sequenceEqual(Enumerable\fromList({'duck', 'duck', 'goose'})) == true
assert tmp\sequenceEqual(Enumerable\fromList({'duck', 'duck', 'duck'})) == false
assert tmp\sequenceEqual(Enumerable\fromList({'duck', 'duck', 'duck'}), isSameType) == true

--single
assert Enumerable\fromList({'duck'})\single! == 'duck'
assert lemonade\single((a) -> #a == 8) == 'lemonade'

--singleOrDefault
assert Enumerable\fromList({'duck'})\singleOrDefault('goose') == 'duck'
assert lemonade\singleOrDefault('goose', (a) -> #a == 8) == 'lemonade'
assert lemonade\singleOrDefault('goose', (a) -> #a == 9) == 'goose'

--skip
assert isSame(lemonade\skip(4)\toList!, {'lemonade','here'})

--skipLast
assert isSame(lemonade\skipLast(4)\toList!, {'get','your'})

--skipWhile
assert isSame(lemonade\skipWhile((a) -> #a < 6)\toList!, {'lemonade','here'})

--sum
assert numbers\sum! == 636
assert lemonade\sum((a) -> #a) == 26

--take
assert isSame(lemonade\take(2)\toList!, {'get','your'})

--takeLast
assert isSame(lemonade\takeLast(2)\toList!, {'lemonade','here'})

--takeWhile
assert isSame(lemonade\takeWhile((a) -> #a < 6)\toList!, {'get','your','ice','cold'})

--thenBy  
--TODO: test with custom comparer
assert isSame(lemonade\orderBy((a) -> #a)\thenBy((a) -> a)\toList!,
  {'get','ice','cold','here','your','lemonade'})

--thenByDescending  
--TODO: test with custom comparer
assert isSame(lemonade\orderByDescending((a) -> #a)\thenByDescending((a) -> a)\toList!,
  {'lemonade','your','here','cold','ice','get'})

--toArray
assert isSame(mixed\toArray!, {[1]:1, [2]:2, [3]:3, [4]:'apple', [5]:'fig', [6]:'kiwi'})

--toDictionary
assert isSame(lemonade\toDictionary(((a)-> a), (a) -> #a),
  { get: 3, your: 4, ice: 3, cold: 4, lemonade: 8, here: 4 })

--toEnumerable
assert isSame(lemonade\toEnumerable!, lemonade)

--toHashSet
assert isSame(lemonade\toHashSet!,
  { get: true, your: true, ice: true, cold: true, lemonade: true, here: true })

--toList
assert isSame(mixed\toList!, {1,2,3,'apple', 'fig', 'kiwi'})

--toLookup
assert isSame(lemonade\toLookup((a) -> #a),
{ 
  [3]:{'get','ice'}, 
  [4]:{'your','cold','here'}, 
  [8]:{'lemonade'} 
})

--union
assert isSame(numbers\union(mixed)\toList!, {1,2,3,10,100,200,300,'apple','fig','kiwi'})

--where
assert isSame(lemonade\where((a) -> #a < 4)\toList!
  {'get','ice'})
assert isSame(numbers\where((a) -> a * a < 150)\toList!
  {1,2,3,10,10,10})

--zip
assert isSame(numbers\zip(mixed)\toList!,
  { {1,1}, {2,2}, {3,3}, {10,'apple'}, {10,'fig'}, {10,'kiwi'} })
assert isSame(lemonade\zip(mixed, (a,b) -> 'step '..b..': print "'..a..'"')\toList!,
{
  'step 1: print "get"',
  'step 2: print "your"',
  'step 3: print "ice"',
  'step apple: print "cold"',
  'step fig: print "lemonade"',
  'step kiwi: print "here"'
})

print 'All Tests Passed'