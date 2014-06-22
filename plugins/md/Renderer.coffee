marked = require("marked")
highlightJs = require("highlight.js")
_ = require("lodash")

class Renderer
  @configure: (config = {}) ->
    @config = config

  constructor: (options = {})->
    @config =
      highlight: (code) ->
        highlightJs.highlightAuto(code).value

    _.merge @config, Renderer.config, options

  render: (content, context, done) ->
    marked.setOptions @config
    done null, marked(content)

module.exports = Renderer
