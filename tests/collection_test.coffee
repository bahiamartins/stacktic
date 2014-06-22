Collection = require("../lib/Collection")

collection = (items) ->
  items ||= [{a: 1, b: 1},{a: 2, b: 2},{a: 3, b: 3}]
  new Collection(items)

describe "Collection", ->
  describe "#toArray", ->
    it "should return an array with the right size", ->
      collection().toArray().should.be.instanceof(Array).and.have.lengthOf(3)

    it "should return an array of clones if clone is passed", ->
      item = {a: 1}
      ary1 = collection([item]).toArray()
      ary2 = collection([item]).toArray(clone: true)
      item.a = 2
      ary1.should.eql([{a: 2}])
      ary2.should.eql([{a: 1}])

  describe "#first", ->
    it "should return first item", ->
      collection().first().should.eql({ a: 1, b: 1 })

  describe "#last", ->
    it "should return last item", ->
      collection().last().should.eql({ a: 3, b: 3 })

  describe "#paginate", ->
    it "Should paginate right", ->
      collection([1..10]).paginate(3).toArray().should.eql [
        { page: 1, items: [1..3] },
        { page: 2, items: [4..6] },
        { page: 3, items: [7..9] },
        { page: 4, items: [10] }
      ]

    it "Should paginate empty to empty collection", ->
      collection([]).paginate(3).size().should.equal(0)
  
  describe "#offset", ->
    it "should return offseted collection", ->
      collection().offset(1).toArray().should.eql([{ a: 2, b: 2 }, { a: 3, b: 3 }])
    it "should return full collection if false is passed", ->
      collection().offset(false).toArray().should.eql([{a: 1, b: 1},{a: 2, b: 2},{a: 3, b: 3}])

  describe "#limit", ->
    it "should return limited collection", ->
      collection().limit(1).toArray().should.eql([{ a: 1, b: 1 }])
    it "should return full collection if false is passed", ->
      collection().limit(false).toArray().should.eql([{a: 1, b: 1},{a: 2, b: 2},{a: 3, b: 3}])

  describe "#merge", ->
    it "should merge properties from object", ->
      collection().merge({c: 0}).toArray().should.eql([{a: 1, b: 1, c: 0},{a: 2, b: 2, c: 0},{a: 3, b: 3, c: 0}])
    
    it "should merge properties from collection", ->
      collection().merge(collection([{c: 0}])).toArray().should.eql([{a: 1, b: 1, c: 0},{a: 2, b: 2, c: 0},{a: 3, b: 3, c: 0}])

    it "should merge properties from array", ->
      collection().merge([{c: 0}, {d: 1}]).toArray().should.eql([{a: 1, b: 1, c: 0, d: 1},{a: 2, b: 2, c: 0, d: 1},{a: 3, b: 3, c: 0, d: 1}])

    it "should not complain if nothing is passed", ->
      collection().merge().toArray().should.eql([{a: 1, b: 1},{a: 2, b: 2},{a: 3, b: 3}])

  describe "#sort", ->
    it "should sort elems and return the same collection", ->
      orig = collection([1,3,2])
      res = orig.sort()
      orig.toArray().should.eql([1,2,3])

  describe "#concat", ->
    it "should concatenate collections and return a new collection", ->
      orig = collection([1..3])
      res = orig.concat(collection([4..6]))
      res.toArray().should.eql([1..6])
      orig.toArray().should.eql([1..3])

  describe "#append", ->
    it "should append a collection to another modifing the original", ->
      orig = collection([1..3])
      res = orig.append(collection([4..6]))
      res.toArray().should.eql([1..6])
      orig.toArray().should.eql([1..6])

  describe "#prepend", ->
    it "should prepend a collection to another modifing the original", ->
      orig = collection([4..6])
      res = orig.prepend(collection([1..3]))
      res.toArray().should.eql([1..6])
      orig.toArray().should.eql([1..6])

  describe "#push", ->
    it "Should push item", ->
      collection([1..3]).push(4).toArray().should.eql([1..4])

  describe "#unshift", ->
    it "Should unshift item", ->
      collection([2..4]).unshift(1).toArray().should.eql([1..4])

  describe "#pop", ->
    it "Should pop and return item", ->
      coll = collection([1..3])
      coll.pop().should.equal(3)
      coll.toArray().should.eql([1..2])

  describe "#shift", ->
    it "Should shift and return item", ->
      coll = collection([1..3])
      coll.shift().should.equal(1)
      coll.toArray().should.eql([2..3])

  #
  # Lodash delegated methods
  #

  describe "#at", ->
    it "should return correspondig item at provided index", ->
      (collection().at(-1) is undefined).should.be.true
      collection().at(0).should.eql({ a: 1, b: 1 })
      collection().at(1).should.eql({ a: 2, b: 2 })
      collection().at(2).should.eql({ a: 3, b: 3 })
      (collection().at(3) is undefined).should.be.true

  describe "#contains", ->
    it "Should return true if collection contains an item", ->
      collection([1..3]).contains(3).should.be.true

    it "Should return false if collection does not contain an item", ->
      collection([1..3]).contains(4).should.be.false

  describe "#countBy", ->
    it "Should count values by key", ->
      collection([{a:"A"}, {a: "A"}, {a: "B"}]).countBy('a').should.eql({"A": 2, "B": 1})      

  describe "#every", ->
    it "Should return true if all values matches", ->
      collection([{a: 1, b: 1}, {a: 1, b: 2}]).every({a: 1}).should.be.true

    it "Should return false if some values not matches", ->
      collection([{a: 1, b: 1}, {a: 1, b: 2}]).every({b: 1}).should.be.false

  describe "#filter", ->
    it "Should filter by keys", ->
      collection([{a:"A"}, {a: "A"}, {a: "B"}]).filter({a: "A"}).toArray().should.eql([{a:"A"}, {a: "A"}])

    it "Should filter by fn", ->
      fn = (item) ->
        item.a == "A"
      collection([{a:"A"}, {a: "A"}, {a: "B"}]).filter(fn).toArray().should.eql([{a:"A"}, {a: "A"}])

  describe "#find", ->
    it "Should find by keys", ->
      collection([{a:"A"}, {a: "A"}, {a: "B", b: 1}, {a: "B", b: 2}]).find({a: "B"}).should.eql({a:"B", b: 1})

    it "Should find by fn", ->
      fn = (item) ->
        item.a == "B"
      collection([{a:"A"}, {a: "A"}, {a: "B", b: 1}, {a: "B", b: 2}]).find(fn).should.eql({a:"B", b: 1})

  describe "#findLast", ->
    it "Should findLast by keys", ->
      collection([{a:"A"}, {a: "A"}, {a: "B", b: 1}, {a: "B", b: 2}]).findLast({a: "B"}).should.eql({a:"B", b: 2})

    it "Should findLast by fn", ->
      fn = (item) ->
        item.a == "B"
      collection([{a:"A"}, {a: "A"}, {a: "B", b: 1}, {a: "B", b: 2}]).findLast(fn).should.eql({a:"B", b: 2})

  describe "#forEach", ->
    it "Should be chainable", ->
      collection().forEach(->).should.be.instanceOf(Collection)

    it "Should invoke callback for each item", ->
      called = 0
      coll = collection()
      items = coll.toArray()

      coll.forEach (item) -> 
        item.should.eql(items[called]) 
        called++

      called.should.equal(3)

    it "It should break returning false", ->
      called = 0
      coll = collection()
      items = coll.toArray()

      coll.forEach (item) -> 
        item.should.eql(items[called]) 
        called++
        false

      called.should.equal(1)


  describe "#forEachRight", ->
    it "Should be chainable", ->
      collection().forEachRight(->).should.be.instanceOf(Collection)

    it "Should invoke callback for each item", ->
      called = 3
      coll = collection()
      items = coll.toArray()

      coll.forEachRight (item) -> 
        called--
        item.should.eql(items[called]) 

      called.should.equal(0)

  describe "#groupBy", ->
    it "Should group by keys", ->
      items = [{a:"A"}, {a: "A"}, {a: "B"}]
      expected = {"A": {items: [{a: "A"}, {a: "A"}]}, "B": {items: [{a: "B"}]}}
      collection(items).groupBy('a').should.eql(expected)

  describe "#indexBy", ->
     it "Should index keys", ->
      items = [{a:"A"}, {a: "A"}, {a: "B"}]
      expected = {"A": {items: [{a: "A"}]}, "B": {items: [{a: "B"}]}}
      collection(items).indexBy('a').should.eql(expected)

  describe "#invoke", ->
    it "Should invoke methods on items", ->
      items = [[5, 1, 7], [3, 2, 1]]
      expected = [[1, 5, 7], [1, 2, 3]]
      collection(items).invoke("sort").should.eql(expected)

  describe "#map", ->
    it "Should map items", ->
      items = [1..3]
      expected = [3, 6, 9]
      fn = (n) -> n * 3
      collection(items).map(fn).toArray().should.eql(expected)

  describe "#max", ->
    it "Should return the max item by key", ->
      collection().max('a').should.eql({a: 3, b: 3})

  describe "#min", ->
    it "Should return the min item by key", ->
      collection().min('a').should.eql({a: 1, b: 1})

  describe "#pluck", ->
    it "Should pluck a collection", ->
      collection().pluck('a').should.eql([1,2,3])      

  describe "#reject", ->
    it "should return filtered collection", ->
      collection().reject(a: 2).toArray().should.eql([{a: 1, b: 1}, {a: 3, b: 3}])

  describe "#sample", ->
     it "Should return a new collection with an item from the original one", ->
        coll = collection([1..10])
        coll.contains(coll.sample().first())
    
  describe "#shuffle", ->
      it "Shoudl return a new collection (pretty much impossible to test further)", ->
        collection().shuffle().should.be.instanceOf(Collection)

  describe "#size", ->
    it "should return the right size", ->
      collection().size().should.equal(3)

  describe "#slice", ->
    it "should return right slices", ->
      collection().slice(1,2).toArray().should.eql([{ a: 2, b: 2 }])
      collection().slice(1).toArray().should.eql([{ a: 2, b: 2 }, { a: 3, b: 3 }])

  describe "#some", ->
    it "Should return true if any values matches", ->
      collection([{a: 1, b: 1}, {a: 1, b: 2}]).some({b: 1}).should.be.true

    it "Should return false if no values matches", ->
      collection([{a: 1, b: 1}, {a: 1, b: 2}]).some({a: 2}).should.be.false


  describe "#sortBy", ->
    it "Should sort by key", ->
      items = [
        { 'name': 'barney',  'age': 36 }
        { 'name': 'fred',    'age': 40 }
        { 'name': 'barney',  'age': 26 }
        { 'name': 'fred',    'age': 30 }
      ]
      expected = [
        { 'name': 'barney',  'age': 26 }
        { 'name': 'fred',    'age': 30 }
        { 'name': 'barney',  'age': 36 }
        { 'name': 'fred',    'age': 40 }
      ]
      collection(items).sortBy('age').toArray().should.eql(expected)

    it "Should sort by in descending order", ->
      items = [
        { 'name': 'barney',  'age': 36 }
        { 'name': 'fred',    'age': 40 }
        { 'name': 'barney',  'age': 26 }
        { 'name': 'fred',    'age': 30 }
      ]
      expected = [
        { 'name': 'fred',    'age': 40 }
        { 'name': 'barney',  'age': 36 }
        { 'name': 'fred',    'age': 30 }
        { 'name': 'barney',  'age': 26 }
      ]
      collection(items).sortBy('age', 'desc').toArray().should.eql(expected)


  describe "#where", ->
    it "should return filtered collection", ->
      collection().where(a: 2).toArray().should.eql([{ a: 2, b: 2 }])

  describe "#reduce", ->
    it "should reduce left", ->
      fn = (acc, item) -> acc + item.a
      collection().reduce(fn, 0).should.eql(6)

  describe "#reduceRight", ->
    it "should reduce right", ->
      fn = (acc, item) -> acc + item.a
      collection().reduceRight(fn, 0).should.eql(6)

  #
  # Aliases
  #
  describe "#include", ->
    it "Should be an alias", ->
      Collection::include.should.be.a.Function
      (Collection::include is Collection::contains).should.be.true
  
  describe "#all", ->
    it "Should be an alias", ->
      Collection::all.should.be.a.Function
      (Collection::all is Collection::every).should.be.true
  
  describe "#select", ->
    it "Should be an alias", ->
      Collection::select.should.be.a.Function
      (Collection::select is Collection::filter).should.be.true
  
  describe "#detect", ->
    it "Should be an alias", ->
      Collection::detect.should.be.a.Function
      (Collection::detect is Collection::find).should.be.true
  
  describe "#findWhere", ->
    it "Should be an alias", ->
      Collection::findWhere.should.be.a.Function
      (Collection::findWhere is Collection::find).should.be.true
  
  describe "#each", ->
    it "Should be an alias", ->
      Collection::each.should.be.a.Function
      (Collection::each is Collection::forEach).should.be.true
  
  describe "#eachRight", ->
    it "Should be an alias", ->
      Collection::eachRight.should.be.a.Function
      (Collection::eachRight is Collection::forEachRight).should.be.true
  
  describe "#collect", ->
    it "Should be an alias", ->
      Collection::collect.should.be.a.Function
      (Collection::collect is Collection::map).should.be.true

  describe "#foldl", ->
    it "Should be an alias", ->
      Collection::foldl.should.be.a.Function
      (Collection::foldl is Collection::reduce ).should.be.true

  describe "#inject", ->
    it "Should be an alias", ->
      Collection::inject.should.be.a.Function
      (Collection::inject is Collection::reduce).should.be.true
  describe "#foldr", ->
    it "Should be an alias", ->
      Collection::foldr.should.be.a.Function
      (Collection::foldr is Collection::reduceRight).should.be.true

  describe "#any", ->
    it "Should be an alias", ->
      Collection::any.should.be.a.Function
      (Collection::any is Collection::some).should.be.true

