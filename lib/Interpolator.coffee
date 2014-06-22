_ = require("lodash")

class Interpolator
  @defaultRegex = /<%=([\s\S]+?)%>/g

  constructor: (@regex = Interpolator.defaultRegex) ->

  interpolate: (txt, data) ->
    _.template(txt, data, {
      escape: false
      evaluate: false
      interpolate: @regex
    })

  interpolateObject: (object, data) ->
    self = @
    traverse = (obj) ->
      for key, value of obj
        if value?
          if typeof value is "string"
            obj[key] = self.interpolate(value, data)
          
          if typeof value is "object"
            traverse(value)

    traverse object

    object
    
module.exports = Interpolator