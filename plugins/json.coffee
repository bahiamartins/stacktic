_ = require('lodash')

module.exports = (stacktic) ->
  stacktic.Model.parseJson = (opts = {}) ->
    @addCallback 'validate:before', (item) ->
      parsed = JSON.parse(item.$content)
      _.merge(item, parsed)
      item.$content = ""
