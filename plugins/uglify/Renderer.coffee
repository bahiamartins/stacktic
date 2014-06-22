UglifyJS = require("uglify-js")
_ = require('lodash')

class Renderer
  @configure: (config = {}) ->
    @config = config

  constructor: (options = {})->
    @config = {}
    _.merge @config, Renderer.config, options, {fromString: true}

  render: (content, context, done) ->
    result = UglifyJS.minify(content, @config)
    done null, result.code

module.exports = Renderer