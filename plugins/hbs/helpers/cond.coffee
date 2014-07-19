module.exports = (stacktic) ->
  stacktic.on 'hbs:registered', (hbs) ->
    hbs.Handlebars.registerHelper "eq", (v1, v2, options) ->
      (v1 is v2)?options.fn(this):options.inverse(this)

    hbs.Handlebars.registerHelper "ne", (v1, v2, options) ->
      (v1!=v2)?options.fn(this):options.inverse(this)

    hbs.Handlebars.registerHelper "lt", (v1, v2, options) ->
      (v1<v2)?options.fn(this):options.inverse(this)

    hbs.Handlebars.registerHelper "lte", (v1, v2, options) ->
      (v1<=v2)?options.fn(this):options.inverse(this)

    hbs.Handlebars.registerHelper "gt", (v1, v2, options) ->
      (v1>v2)?options.fn(this):options.inverse(this)

    hbs.Handlebars.registerHelper "gte", (v1, v2, options) ->
      (v1>=v2)?options.fn(this):options.inverse(this)
