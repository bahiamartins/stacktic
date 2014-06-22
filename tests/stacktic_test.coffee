stacktic = require ".."

stacktic
  src: "tests/_fixtures"
  dest: "tests/_fixtures/_output"
  logger:
    verbose: true

.model "Page", ->
  @dataSource 'fs', {src: 'pages/**/*'}
  @parseYfm()

.controller "Pages", ->
  @context.nav = @models.Page.where(nav: true)
  @route "/", @models.Page.where(slug: "home")
  @route "/:{slug}/", @models.Page.reject(slug: "home")

.build (err) ->
  if err
    console.error err.stack
    process.exit(1)