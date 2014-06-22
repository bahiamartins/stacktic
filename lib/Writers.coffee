_ = require('lodash')
async = require('async')

class Writers
  constructor: (@config) ->
    @writers = {}

  registerWriter: (type, writer) ->
    @writers[type] = writer
    @enabledWriters = {}

  enableWriter: (name) ->
    @enabledWriters[name] = true

  disableWriter: (name) ->
    delete @enabledWriters[name]


  resolveWriter: (type) ->
    Writer = @writers[type]
    
    if !Writer
      throw(new Error( "Writer not found: #{type}" ))

    new Writer()

  write: (objects, done) ->
    self = @
    writers = _.map( _.keys(self.enabledWriters), (type) -> self.resolveWriter(type) )
    async.applyEach _.map(writers, (writer) -> _.bind(writer.write, writer)), objects, done

module.exports = Writers  

