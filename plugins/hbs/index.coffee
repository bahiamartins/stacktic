HandlebarsRenderingEngine = require('./HandlebarsRenderingEngine')

module.exports = (stacktic) ->
  stacktic.use(require('./helpers/md'))
  stacktic.use(require('./helpers/moment'))
  stacktic.use(require('./helpers/url'))
  stacktic.use(require('./helpers/config'))
  stacktic.use(require('./helpers/cond'))

  HandlebarsRenderingEngine.configure(stacktic.config, stacktic.config.get('hbs', {}))
  stacktic.registerRenderingEngine('hbs', HandlebarsRenderingEngine)
  stacktic.Handlebars = HandlebarsRenderingEngine.Handlebars
  stacktic.emit('hbs:registered', HandlebarsRenderingEngine)