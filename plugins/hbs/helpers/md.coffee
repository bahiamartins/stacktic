marked = require("marked")
highlightJs = require("highlight.js")
_ = require("lodash")

module.exports = (stacktic) ->
  stacktic.on 'hbs:registered', (hbs) ->
    markedDefaults =
      gfm: true
      tables: true
      sep: "\n"
      highlight: (code) ->
        highlightJs.highlightAuto(code).value

    hbs.Handlebars.registerHelper "md", (options) ->
      opts = _.extend({}, markedDefaults, options.hash or {})
      marked.setOptions opts
      new hbs.Handlebars.SafeString(marked(options.fn(this)))
