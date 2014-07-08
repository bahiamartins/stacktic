moment = require('moment')

module.exports = (stacktic) ->
  stacktic.on 'hbs:registered', (hbs) ->
    hbs.Handlebars.registerHelper "formatDate", (date, options) ->
      moment(date).format(options.hash.format or 'DD MMMM - YYYY');
