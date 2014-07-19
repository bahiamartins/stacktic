module.exports = (stacktic) ->
  stacktic.on 'hbs:registered', (hbs) ->
    hbs.Handlebars.registerHelper "config", (propname, options) ->
      stacktic.config.get(propname, (options.hash and options.hash.default));
