momentHelpers = require("handlebars-helper-moment")

module.exports = (stacktic) ->
  stacktic.on 'hbs:registered', (hbs) ->
    hbs.Handlebars.registerHelper momentHelpers.moment
    hbs.Handlebars.registerHelper momentHelpers.duration