Renderer = require('./Renderer')

module.exports = (stacktic) ->
  Renderer.host = stacktic.config.get('host')
  stacktic.registerRenderingEngine('sitemap', Renderer)