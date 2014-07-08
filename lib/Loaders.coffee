_ = require('lodash')
async = require('async')
validate = require("validate.js")
Collection = require('./Collection')

class Loaders
  constructor: (@config = {}) ->
    @drivers = {}

  registerDriver: (name, driver) ->
    if driver.prototype.load
      @drivers[name] = driver
    else # allow to register a simple function
      @drivers[name] = ->
      @drivers[name].prototype.load = driver

  resolveDriver: (type, opts = {}) ->
    Driver = @drivers[type]
    if !Driver
      throw(new Error( "Driver not found: #{type}" ))

    new Driver(opts)

  loadModel: (ModelClass, done) ->
    fns = _.map ModelClass.dataSources, (ds) =>
      opts = _.extend({}, @options, ds.options)
      driver = @resolveDriver(ds.type, opts)
      
      return (done) ->
        if driver.load.length == 2
          driver.load(opts, done)
        else
          driver.load(done)

    async.parallel fns, (err, collections) ->
      ModelClass.collection = new Collection([])

      for items in collections
        for item in items
          model = new ModelClass(item)
          model.$model = ModelClass
          model.$type = ModelClass.name

          for cb in ModelClass.callbacks['load:after']
            cb(model)

          for cb in ModelClass.callbacks['validate:before']
            cb(model)

          skip = false
          model.$valid = true

          for validation in ModelClass.validations
            errors = validate(model, validation.constraints)
            if errors
              model.$errors = errors
              model.$valid = false

              if validation.invalid is 'skip'
                console.warn("Invalid model", errors)
                skip = true

              else if validation.invalid is 'report'
                console.warn("Invalid model", errors)

              else if _.isFunction(validation.invalid)
                skip = !validation.invalid(model)

              else
                err = new Error("Invalid Model")
                err.model = model
                throw err

          if model.$valid
            for cb in ModelClass.callbacks['validate:success']
              cb(model)
          else
            for cb in ModelClass.callbacks['validate:error']
              cb(model)

          for cb in ModelClass.callbacks['validate:after']
            cb(model)

          if not skip
            ModelClass.collection.items.push model

      for cb in ModelClass.callbacks['collection:ready']
        cb(ModelClass)

      done()

  load: (modelClasses, done) ->
    self = @
    loadFn = (modelClass, callback) ->
      self.loadModel(modelClass, callback)

    async.each modelClasses, loadFn, done

module.exports = Loaders
