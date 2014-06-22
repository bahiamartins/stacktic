_ = require("lodash")
{EventEmitter} = require('events')

Collection = require("./Collection")
Interpolator = require("./Interpolator")

class Route extends EventEmitter
  @interpolator = new Interpolator(/\:\{([\s\S]+?)}/g)

  constructor: (@path, @globalContext = {}) ->
    @contextFn = _.noop

  bind: (collection) ->
    newItems = new Collection(collection)    
    @items ||= new Collection([])
    self = @
    newItems.forEach (item) ->
      if not item? or !_.isObject(item)
        throw new Error('Cannot bind item')
      
      self.emit('bind:before', item)
      item.$path = Route.interpolator.interpolate(self.path, item)
      self.items.push(item)
      item.emit('bound', item) if item.emit
      self.emit('bind:after', item)
      true # this is due to Collection#forEach would break if accidentally returning false
    
    @

  setLocalContext: (fnOrObject, options = {}) ->
    if _.isFunction(fnOrObject)
      @contextFn = fnOrObject
    else
      @contextFn = (item) ->
        toBeMerged = fnOrObject
        if item? and options.interpolate
          toBeMerged = Route.interpolator.interpolateObject(fnOrObject, item)

        _.extend @, toBeMerged

  @::context = @::setLocalContext

  addRenderer: (renderer, opts) ->
    @renderers ||= []
    @renderers.push({
      renderer: renderer,
      options: opts
    })
    @
  
  @::render = @::addRenderer

  computeContext: (item) ->
    ctx = _.cloneDeep @globalContext
    if item
      @contextFn.call(ctx, item)
    else
      @contextFn.call(ctx)

    ctx.$renderers = @renderers if @renderers
    ctx.$route = @path
    ctx.$path = (item and item.$path) or @path
    ctx.$file =  (if ctx.$path.match(/\/$/) then ctx.$path + "index.html" else ((if ctx.$path.match(/\./) then ctx.$path else ctx.$path + ".html")))
    ctx.$current = item if item
    ctx

  getRenderables: ->
    self = @
    if @isBound()
      (@items.map (item) ->
        self.computeContext(item) 
      ).toArray()
    else
      [@computeContext()]

  isBound: ->
    @items?

module.exports = Route