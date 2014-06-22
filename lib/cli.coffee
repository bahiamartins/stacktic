program = require 'commander'
fs      = require 'fs'
path    = require 'path'

pkg = JSON.parse(
  fs.readFileSync(
    path.resolve(__dirname, '../package.json'), encoding: 'utf8'
  )
)

module.exports = ->
  program
    .version(pkg.version)
  program.parse(process.argv);

  require(path.resolve(process.cwd(), 'stackticfile'))