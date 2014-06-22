HandlebarsRenderingEngine = require('./HandlebarsRenderingEngine')
mdHelper     = require('./helpers/md')
momentHelper = require('./helpers/moment')

module.exports = (stacktic) ->
  stacktic.use(mdHelper)
  stacktic.use(momentHelper)

  HandlebarsRenderingEngine.configure(stacktic.config, stacktic.config.get('hbs', {}))
  stacktic.registerRenderingEngine('hbs', HandlebarsRenderingEngine)
  stacktic.emit('hbs:registered', HandlebarsRenderingEngine)