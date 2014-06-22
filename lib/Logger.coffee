_ = require('lodash')
{inspect} = require('util')
{Log} = require('grunt-legacy-log')

class Singleton
  instance = null
  class Logger
    constructor: (options = {}) ->
      @log = new Log()
      @verbose = @log.verbose
      @setOptions(options)
      @mute = false

    setMute: (mute) ->
      @mute = mute
      @

    isMute: ->
      @mute

    setOptions: (options = {}) ->
      _.assign(@log.options, options)
      @

    setVerbose: (verbose) ->
      @log.options.verbose = verbose
      @

  @getInstance: () ->
    instance ?= new Logger()

module.exports = Singleton