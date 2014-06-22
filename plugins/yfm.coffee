_ = require('lodash')
yfm = require('yfm')

module.exports = (stacktic) ->
  stacktic.Model.parseYfm = (opts = {}) ->
    @addCallback 'validate:before', (item) ->
      parsed = yfm(item.$content)
      _.merge(item, parsed.context)
      item.$content = parsed.content