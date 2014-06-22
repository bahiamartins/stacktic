slug = require('slug')
_ = require('lodash')

module.exports = (stacktic) ->
  stacktic.Model.slug = (attrOrFn = 'title') ->
    @addCallback 'validate:before', (item) ->
      if not item.$slug
        if _.isFunction(attrOrFn)
          item.$slug = attrOrFn(item)
        else
          item.$slug = stacktic.Model.slug.slugFn(item[attrOrFn])

  stacktic.Model.slug.slugFn = (string) ->
    slug(string, "-").toLowerCase()
