Renderer = require('./Renderer')

module.exports = (stacktic) ->
  Renderer.configure(stacktic.config.get('toc', {}))
  stacktic.registerRenderingEngine('toc', Renderer)