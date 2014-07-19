url = require('url')

module.exports = (stacktic) ->
  stacktic.on 'hbs:registered', (hbs) ->
    hbs.Handlebars.registerHelper "url", (path) ->
      host = stacktic.config.get('host')
      throw "You must pass 'host' to stacktic config in order to use url helper" unless host
      url.resolve(host, (path || '/'));
