_ = require("lodash")
{EventEmitter} = require('events')
pathModule = require('path')
Collection = require("./Collection")
Interpolator = require("./Interpolator")

class Route extends EventEmitter
  @interpolator = new Interpolator(/\:\{([\s\S]+?)}/g)

  constructor: (@path, @globalContext = {}) ->
    @contextFn = _.noop

  bind: (collection) ->
    # collection is a model if a function is passed
    if _.isFunction(collection)
      collection = collection.collection
    
    newItems = new Collection(collection)    
    @items ||= new Collection([])
    self = @
    newItems.forEach (item) ->
      if not item? or !_.isObject(item)
        throw new Error('Cannot bind item')
      
      self.emit('bind:before', item)
      item.$path = self.pathFor(item)
      self.items.push(item)
      item.emit('bound', item) if item.emit
      self.emit('bind:after', item)
      true # this is due to Collection#forEach would break if accidentally returning false
    
    @

  pathFor: (item) ->
    if item
      pathModule.join(@globalContext.$root, Route.interpolator.interpolate(@path, item))
    else   
      pathModule.join(@globalContext.$root, @path)
  
  fileFor: (item, path) ->
    if path.match(/\/$/) 
      path + "index.html" 
    else 
      if path.match(/\./)
        path 
      else 
        path + ".html"

  setLocalContext: (fnOrObject, options = {}) ->
    if _.isFunction(fnOrObject)
      @contextFn = fnOrObject
    else
      @contextFn = (item) ->
        toBeMerged = fnOrObject
        if item? and options.interpolate
          toBeMerged = Route.interpolator.interpolateObject(fnOrObject, item)

        _.extend @, toBeMerged
    @

  @::context = @::setLocalContext

  addRenderer: (renderer, opts) ->
    if renderer is false
      @renderers = []
    else
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
    ctx.$path = @pathFor(item)
    ctx.$file =  @fileFor(item, ctx.$path)
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