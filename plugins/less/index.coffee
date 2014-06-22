Renderer = require('./Renderer')

module.exports = (stacktic) ->
  Renderer.configure(stacktic.config, stacktic.config.get('less', {}))
  stacktic.registerRenderingEngine "less", Renderer