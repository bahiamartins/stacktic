Renderer = require('./Renderer')

module.exports = (stacktic) ->
  Renderer.configure(stacktic.config.get('uglify', {}))
  stacktic.registerRenderingEngine('uglify', Renderer)