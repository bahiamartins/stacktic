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
    stream = @options.stream is true
    logger = FileDriver.logger
    loadFn = (file, cb) ->
      logger.verbose.writeln("[FileDriver] Loading #{file}")

      item = {
        $fs: {
          path: file
          base: path.resolve(base)
          pathFromBase: file.slice(path.resolve(base).length + 1)
          extname: path.extname(file)
          basename: path.basename(file)
        }
      }

      # If stream is set just create a read stream
      if stream
        item.$content = fs.createReadStream(file)
        cb null, item
      else
        fs.readFile file, {encoding: 'utf8'}, (err, data) ->
          throw err if err
          logger.verbose.ok("[FileDriver] Loaded #{file}")

          item.$content = data
          cb null, item

    if not @options.src?
      throw new Error("you must provide src option for fs datasources")

    srcs = @options.src
    if not _.isArray(srcs)
      srcs = [srcs]

    files = []
    excluded = []
    srcs.forEach (src) ->
      isNegated = false
      if src.match(/^\!/)
        isNegated = true
        src = src.slice(1)

      resolvedSrc = path.resolve(base, src)
      globRes = (glob.sync(resolvedSrc) or [])
      if globRes.length is 0
        logger.log.warn("[FileDriver] Warning: datasource '#{src}' was empty.")

      globRes.forEach (file) ->
        if fs.lstatSync(file).isFile()
          if isNegated
            excluded.push(file)
          else
            files.push(file)

    files = _.difference(files, excluded)

    if files.length is 0
      done(null, [])
    else
      async.map files, loadFn, (err, items) ->
        logger.verbose.ok('[FileDriver] All files loaded')
        done(null, items)

module.exports = FileDriver
