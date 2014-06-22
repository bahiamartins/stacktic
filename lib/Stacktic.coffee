# 
# External deps
# 
path = require('path')
_ = require('lodash')
{EventEmitter} = require('events')

# 
# Local deps
#
Config     = require('./Config')
Loaders    = require('./Loaders')
Renderers  = require('./Renderers')
Writers    = require('./Writers')
Collection = require('./Collection')
Logger     = require('./Logger')


Model = require('./Model')
Controller = require('./Controller')



class Stacktic extends EventEmitter

  constructor: (config) ->
    # 
    # Useful for plugins
    # 
    @Model      = Model
    @Controller = Controller
    @Collection = Collection
    @logger     = new Logger.getInstance()
    @loaders    = new Loaders()
    @renderers  = new Renderers()
    @writers    = new Writers()

    @config = new Config({})
    _.merge @config, config
    _.merge(@logger.log.options, @config.get('logger', {}))
    
    @routes = {}
    @models = {}
    @controllers = []
    
    @context = new Config({})
    @context.models = @models

  setLogger: (logger) ->
    @logger = logger

  getLogger: () ->
    @logger

  registerDataSourceDriver: (name, driver) ->
    @loaders.registerDriver(name, driver)

  registerRenderingEngine: (name, engine) ->
    @renderers.registerEngine(name, engine)

  setDefaultRenderingEngines: (engines, options) ->
    @renderers.setDefaultEngines(engines, options)

  registerWriter: (name, writer) ->
    @writers.registerWriter(name, writer)

  enableWriter: (name) ->
    @writers.enableWriter(name)

  disableWriter: (name) ->
    @writers.enableWriter(name)

  createCollection: (arg = []) ->
    new Collection(arg)

  use: (fn, opts) ->
    if not _.isFunction(fn)
      fn = require(path.resolve(process.cwd(), fn))

    fn(@)
    @

  model: (name, fn) ->
    @models[name] = Model.define(name, fn)
    this

  controller: (name, fn)->
    @controllers.push(fn)
    this

  build: (done) ->
    self = @


    # 
    # Invoking loaders ...
    # 
    self.logger.verbose.writeln('[Stacktic] Invoking loaders ...')

    self.loaders.load _.values(self.models), (err) ->
      self.logger.verbose.writeln('[Stacktic] All models loaded ...')
      try
        self.controllers.forEach (fn)->  
          Controller.define(self.routes, self.context, self.models, fn)          

        self.logger.verbose.writeln('[Stacktic] All controllers loaded ...')
        
        renderables = _.flatten(_.map(_.values(self.routes), (route) -> route.getRenderables()))
        
        # 
        # Routes and global context ready
        # Invoking renderers ...
        #         
        self.logger.verbose.writeln('[Stacktic] Invoking renderers ...')
        self.renderers.render renderables, (err, objects) ->
        
          # 
          # Everything rendered
          # Invoking writers ...
          # 
          self.logger.verbose.writeln('[Stacktic] Invoking writers ...')
          self.writers.write _.flatten(objects), ->
            self.logger.log.ok('[Stacktic] Done.')
            done()

      catch e
        self.logger.log.error('[Stacktic] Aborting due to errors')
        self.logger.verbose.error(e.stack)
        done(e)
      

module.exports = Stacktic
  
