_ = require('lodash')
yfm = require('yfm')

module.exports = (stacktic) ->
  stacktic.Model.parseDates = (attrs...) ->
    @addCallback 'validate:before', (item) ->
      for attr in attrs
        if item[attr]
          item.$rawDates ?= {}
          item.$rawDates[attr] = item[attr]
          item[attr] = new Date(item[attr])