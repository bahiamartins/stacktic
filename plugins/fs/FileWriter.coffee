fs = require("fs")
path = require("path")
mkdirp = require("mkdirp")
async = require("async")

class FileWriter
  @plugin = (stacktic) ->
    FileWriter.configure(stacktic.config, stacktic.config.get('fs', {}))
    stacktic.registerWriter "fs", FileWriter

  @configure = (config, localConfig) ->
    @dest = config.dest or localConfig.dest or process.cwd()

  writeObject: (item, fn) =>
    destFile = path.join(FileWriter.dest, item.$file)
    mkdirp.sync path.dirname(destFile)

    if item.$rendered.constructor and item.$rendered.constructor.name is 'ReadStream'
      source = item.$rendered
      source.on('end', -> fn(null))
      source.pipe(fs.createWriteStream(destFile))
    else
      fs.writeFile destFile, item.$rendered, fn

  write: (items, fn)->
    self = @
    writeFn = (item, callback) ->
      self.writeObject(item, callback)

    async.each items, writeFn, fn

module.exports = FileWriter
