fs   = require("fs")
path = require("path")
glob = require("glob")
async = require("async")
_ = require('lodash')

class FileDriver
  @configure = (config, localConfig) ->
    @::src = config.src or localConfig.src or process.cwd()

  constructor: (@options = {}) ->

  load: (done) =>
    base = @options.base or @src or ""

    logger = FileDriver.logger
    loadFn = (file, cb) ->
      logger.verbose.writeln("[FileDriver] Loading #{file}")
      fs.readFile file, {encoding: 'utf8'}, (err, data) ->
        throw err if err
        logger.verbose.ok("[FileDriver] Loaded #{file}")
        
        item = {
          $content: data
          $fs:
            path: file
            local: file.slice(base.length)
            extname: path.extname(file)
            basename: path.basename(file)
        }
        cb null, item
            


    if not @options.src?
      throw "you must provide src option for fs datasources"

    srcs = @options.src
    if not _.isArray(srcs)
      srcs = [srcs]

    files = []
    srcs.forEach (src) ->
      resolvedSrc = path.resolve(base, src)
      globRes = (glob.sync(resolvedSrc) or [])
      if globRes.length is 0
        logger.log.warn("[FileDriver] glob('#{src}') returned empty array")
      globRes.forEach (file) ->
        if fs.lstatSync(file).isFile()
          files.push(file)

    if files.length is 0
      done(null, [])

    async.map files, loadFn, (err, items) ->
      logger.verbose.ok('[FileDriver] All files loaded')
      done(null, items)

module.exports = FileDriver