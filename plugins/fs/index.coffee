FileDriver = require('./FileDriver')
FileWriter = require('./FileWriter')

module.exports = (stacktic) ->
  FileWriter.configure(stacktic.config, stacktic.config.get('fs', {}))
  FileWriter.logger = stacktic.logger
  stacktic.registerWriter "fs", FileWriter

  FileDriver.configure(stacktic.config, stacktic.config.get('fs', {}))
  FileDriver.logger = stacktic.logger
  stacktic.registerDataSourceDriver 'fs', FileDriver