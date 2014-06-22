{Parser} = require("less")
_ = require('lodash')

class Renderer
  @configure: (config, localConfig) ->
    @config = localConfig
    if config.src and not @config.paths
      @config.paths = [config.src]

  constructor: (options = {})->
    @config = {}
    _.merge @config, Renderer.config, options

  render: (content, context, done) ->
    self = @
    filename = context.$current and context.$current.$fs and context.$current.$fs.path or @config.filename
    lessOpts = {}
    _.assign(lessOpts, {filename: filename}, @config)
    parser = new Parser(lessOpts)
    parser.parse content, (e, tree) ->
      if e
        throw new Error(e)
      else
        done null, tree.toCSS( compress: self.config.compress )

module.exports = Renderer