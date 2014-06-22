_ = require('lodash')
async = require('async')
validate = require("validate.js")
Collection = require('./Collection')

class Loaders
  constructor: (@config = {}) ->
    @drivers = {}

  registerDriver: (name, driver) ->
    @drivers[name] = driver

  resolveDriver: (type, opts = {}) ->
    Driver = @drivers[type]
    if !Driver
      throw(new Error( "Driver not found: #{type}" ))

    new Driver(_.extend({}, @options, opts))

  loadModel: (ModelClass, done) ->
    fns = _.map ModelClass.dataSources, (ds) =>
      Driver = @resolveDriver(ds.type, ds.options)
      Driver.load

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
      
      done()

  load: (modelClasses, done) ->
    self = @
    loadFn = (modelClass, callback) ->
      self.loadModel(modelClass, callback)
    
    async.each modelClasses, loadFn, done

module.exports = Loaders