Renderer = require('./Renderer')

module.exports = (stacktic) ->
  Renderer.configure(stacktic.config.get('md', {}))
  stacktic.registerRenderingEngine('md', Renderer)