_ = require('lodash')
async = require('async')

class Renderers
  constructor: () ->
    @engines = {}
    @defaultEngines = []

  registerEngine: (type, engine) ->
    @engines[type] = engine

  setDefaultEngines: (engines, options = {}) ->
    @defaultEngines = _.map engines, (engine) ->
      {
        renderer: engine,
        options: options[engine] or {}
      }

  resolveEngine: (type, opts = {}) ->
    Engine = @engines[type]
    
    if !Engine
      throw(new Error( "Rendering Engine not found: #{type}" ))

    new Engine(_.extend({}, @options, opts))

  renderRenderable: (renderable, done) ->
    self = @
    
    # always implicitly render copying $content
    renderable.$rendered ||= (renderable.$current and renderable.$current.$content) or ""

    renderers = _.map (renderable.$renderers or self.defaultEngines), (renderer) ->
      self.resolveEngine(renderer.renderer, renderer.options)

    renderFn = (renderer, cb) ->
      renderer.render renderable.$rendered, renderable, (err, rendered) ->
        if not err
          renderable.$rendered = rendered
          cb(null)
        else
          cb(err)

    async.eachSeries renderers, renderFn, (err) ->
      if not err
        done(null, renderable)
      else
        done(err)

  render: (renderables, done) ->
    self = @

    renderFn = (renderable, callback) ->
      self.renderRenderable(renderable, callback)

    async.map(renderables, renderFn, done)    

module.exports = Renderers


