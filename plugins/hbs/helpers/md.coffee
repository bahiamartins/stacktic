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

    hbs.Handlebars.registerHelper "md", (item, options) ->
      if typeof item.fn is 'function'
        options = item    
        opts = _.extend({}, markedDefaults, options.hash or {})
        marked.setOptions opts
        new hbs.Handlebars.SafeString(marked(options.fn(this)))
      else
        opts = _.extend({}, markedDefaults, ((options and options.hash) or {}))
        marked.setOptions opts
        new hbs.Handlebars.SafeString(marked(item.$content))