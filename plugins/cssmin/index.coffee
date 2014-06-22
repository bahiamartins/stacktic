Renderer = require('./Renderer')

module.exports = (stacktic) ->
  stacktic.registerRenderingEngine('cssmin', Renderer)