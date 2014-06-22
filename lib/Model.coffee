_ = require("lodash")
{EventEmitter} = require('events')
Collection = require('./Collection')

class Model extends EventEmitter

  @define = (name, fn) ->
    subClass = class extends @
    subClass.className = name
    subClass.dataSources = []
    subClass.validations = []  
    subClass.callbacks =
      'load:after': []
      'validate:before': []
      'validate:success': []
      'validate:error': []
      'validate:after': []

    fn.apply(subClass)
    subClass

  _.methods(Collection.prototype).forEach (method) =>
    @[method] = (args...) ->
      @collection[method].apply(@collection, args)

  @addDataSource = (type, opts = {}) ->
   @dataSources.push({type: type, options: opts})

  @dataSource = @addDataSource
  
  @addCallback = (type, fn) ->
    @callbacks[type].push(fn)

  @callback = @addCallback

  @addValidation = (constraints, opts = {}) ->
    @validations.push({constraints: constraints, invalid: opts.invalid})

  @validate = @addValidation

  constructor: (obj) ->
    _.merge(@, obj)

module.exports = Model