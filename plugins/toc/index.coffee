Renderer = require('./Renderer')

module.exports = (stacktic) ->
  Renderer.configure(stacktic.config.get('toc', {}))
  Renderer.logger = stacktic.logger
  stacktic.registerRenderingEngine('toc', Renderer)