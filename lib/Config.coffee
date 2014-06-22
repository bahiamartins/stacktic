_ = require('lodash')

process = (obj, key, create) ->
  keys = key.split(".")
  res =
    object: obj
    propname: keys.pop()

  i = 0

  while i < keys.length
    k = keys[i]
    unless res.object[k]?
      if create is true
        res.object[k] = {}
      else
        res.object = {}
        res.propname = null
        return res
    res.object = res.object[k]
    i++
  res


class Config
  constructor: (obj) ->
    _.merge this, obj
  
  get: (path, def) ->
    ret = process(this, path)
    res = (if ret.propname is "" then ret.object else ret.object[ret.propname])
    res = null if res is undefined
    (if (def and (res is null)) then def else res)

  set: (path, value) ->
    ret = process(this, path, true)
    ret.object[ret.propname] = value
    @

module.exports = Config
