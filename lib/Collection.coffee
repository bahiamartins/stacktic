_ = require("lodash")

class Collection
  constructor: (items) ->
    if items instanceof Collection
      @items = items.toArray()
    else if _.isArray(items)
      @items = items
    else if not items?
      @items = [] 
    else
      @items = [items]

  contains: (args...)->
    args.unshift @items
    _.contains.apply(_, args)

  @::include = @::contains

  countBy: (args...)->
    args.unshift @items
    _.countBy.apply(_, args)

  every: (args...)->
    args.unshift @items
    _.every.apply(_, args)

  @::all = @::every
  
  filter: (args...)->
    args.unshift @items
    new Collection( _.filter.apply(_, args) )

  @::select = @::filter

  find: (args...)->
    args.unshift @items
    _.find.apply(_, args)
  
  @::detect = @::find
  @::findWhere = @::find
  
  findLast: (args...)->
    args.unshift @items
    _.findLast.apply(_, args)

  forEach: (args...)->
    args.unshift @items
    _.forEach.apply _, args
    this
  
  @::each = @::forEach
  
  forEachRight: (args...)->
    args.unshift @items
    _.forEachRight.apply _, args
    this

  @::eachRight = @::forEachRight

  groupBy: (args...)->
    args.unshift @items
    res = _.groupBy.apply(_, args)
    _.keys(res).forEach (k) ->
      res[k] = new Collection(res[k])
    res

  indexBy: (args...)->
    args.unshift @items
    res = _.indexBy.apply(_, args)
    _.keys(res).forEach (k) ->
      res[k] = new Collection(res[k])
    res

  invoke: (args...)->
    args.unshift @items
    _.invoke.apply(_, args)

  map: (args...)->
    args.unshift @items
    new Collection( _.map.apply(_, args) )
  
  @::collect = @::map

  max: (args...)->
    args.unshift @items
    _.max.apply(_, args)

  min: (args...)->
    args.unshift @items
    _.min.apply(_, args)

  pluck: (args...)->
    args.unshift @items
    _.pluck.apply(_, args)

  reduce: (args...)->
    args.unshift @items
    _.reduce.apply(_, args)

  @::foldl = @::reduce 
  @::inject = @::reduce

  reduceRight: (args...)->
    args.unshift @items
    _.reduceRight.apply(_, args)

  @::foldr = @::reduceRight

  reject: (args...)->
    args.unshift @items
    new Collection( _.reject.apply(_, args) )

  sample: (args...)->
    args.unshift @items
    new Collection( _.sample.apply(_, args) )

  shuffle: (args...)->
    args.unshift @items
    new Collection( _.shuffle.apply(_, args) )

  some: (args...)->
    args.unshift @items
    _.some.apply(_, args)
  
  @::any = @::some
  
  sortBy: (fnOrKey, order = "asc")->
    res = _.sortBy(@items, fnOrKey)
    if order.toLowerCase() is 'desc'
      res = res.reverse()
    new Collection( res )

  where: (args...)->
    args.unshift @items
    new Collection( _.where.apply(_, args) )

  paginate: (number) ->
    slices = ((array, number) ->
      index = -number
      slices = []
      return array  if number < 1
      while (index += number) < array.length
        s = array.slice(index, index + number)
        slices.push s
      slices
    )(@items, number)
    i = 1
    pages = _.map(slices, (slice) ->
      page: i++
      items: slice
    )
    new Collection(pages)

  slice: (a, b) ->
    new Collection( @items.slice(a, b) )

  offset: (number) ->
    if number is false
      number = 0

    @slice(number)

  limit: (number) ->
    if number is false
      number = @size()
    
    @slice(0, number)

  first: ->
    @items[0]

  last: ->
    @items[@items.length - 1]

  at: (idx) ->
    @items[idx]

  size: ()->
    @items.length

  concat: (coll) ->
    new Collection(@items.concat((new Collection(coll)).items))

  append: (coll) ->
    @items = @items.concat((new Collection(coll)).items)
    @

  prepend: (coll) ->
    @items = (new Collection(coll)).items.concat(@items)
    @

  push: (item) ->
    @items.push(item)
    @

  unshift: (item) ->
    @items.unshift(item)
    @

  pop: () ->
    @items.pop()
  
  shift: () ->
    @items.shift()

  sort: (args ...) ->
    @items.sort.apply(@items, args)
    this

  merge: (object) ->
    args = []
    if object instanceof Collection
      args = object.toArray()
    else if _.isArray(object)
      args = object
    else if not object?
      args = [] 
    else
      args = [object]
    args.unshift null # placeholder for destination item
    _.forEach @items, (item) ->
      args[0] = item
      _.merge.apply _, args

    this

  toArray: (opts) ->
    (if (opts and opts.clone) then _.cloneDeep(@items) else @items)

module.exports = Collection