path = require('path')
Stacktic = require('./Stacktic')

module.exports = (options) ->
  instance = new Stacktic(options)
  instance.use(path.resolve(__dirname, '../plugins/fs'))
  instance.use(path.resolve(__dirname, '../plugins/hbs'))
  instance.use(path.resolve(__dirname, '../plugins/uglify'))
  instance.use(path.resolve(__dirname, '../plugins/cssmin'))
  instance.use(path.resolve(__dirname, '../plugins/less'))
  instance.use(path.resolve(__dirname, '../plugins/md'))
  instance.use(path.resolve(__dirname, '../plugins/slug'))
  instance.use(path.resolve(__dirname, '../plugins/date'))
  instance.use(path.resolve(__dirname, '../plugins/yfm'))
  instance.use(path.resolve(__dirname, '../plugins/json'))
  instance.use(path.resolve(__dirname, '../plugins/toc'))
  instance.use(path.resolve(__dirname, '../plugins/sitemap'))

  instance.setDefaultRenderingEngines ["hbs"]
  instance.enableWriter('fs')
  instance
