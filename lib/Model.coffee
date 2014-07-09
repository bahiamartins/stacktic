_ = require("lodash")
{EventEmitter} = require('events')
Collection = require('./Collection')

class Model extends EventEmitter

  @define = (name, fn) ->
    subClass = class extends @
    subClass.className = name
    subClass.dataSources = []
    subClass.validations = []
    subClass.emitter = new EventEmitter()

    fn.apply(subClass)
    subClass

  _.methods(Collection.prototype).forEach (method) =>
    @[method] = (args...) ->

      # treat models args as collections
      args = args.map (arg) ->
        if arg.collection instanceof Collection
          arg.collection
        else
          arg

      @collection[method].apply(@collection, args)

  # Instances are EventEmitters by extends while this makes
  # class an EventEmitter as well
  _.methods(EventEmitter.prototype).forEach (method) =>
    @[method] = (args...) ->
      @emitter[method].apply(@emitter, args)

  @addCallback = @on
  @callback = @on

  @addDataSource = (type, opts = {}) ->
   @dataSources.push({type: type, options: opts})

  @dataSource = @addDataSource

  @addValidation = (constraints, opts = {}) ->
    @validations.push({constraints: constraints, invalid: opts.invalid})

  @validate = @addValidation

  constructor: (obj) ->
    _.merge(@, obj)

module.exports = Model
