Handlebars = require("handlebars")
_ = require("lodash")
fs = require("fs")
glob = require("glob")
path = require("path")

class HandlebarsRenderingEngine
  @Handlebars = Handlebars

  @configure = (globalConfig = {}, config = {}) ->
    src = globalConfig.src or process.cwd()

    #
    # Partials
    #
    partialsDir = path.resolve(src, config.partialsDir || 'partials')
    partials    = glob.sync(path.join(partialsDir, "**/*"))

    partials.forEach (filename) ->
      partialContent = fs.readFileSync(filename,
        encoding: "utf8"
      )
      id = filename.slice(partialsDir.length).split(".")[0].replace(/^\//, "")
      Handlebars.registerPartial id, partialContent

    #
    # Layouts
    #
    layoutsDir  = path.resolve(src, config.layoutsDir  || 'layouts')
    layoutsFiles = glob.sync(path.join(layoutsDir, "**/*"))
    @layouts = {}
    @layouts[false] = Handlebars.compile("{{{yield}}}")
    @layouts["default"] = @layouts[false]
    layoutsFiles.forEach (filename) =>
      layoutContent = fs.readFileSync(filename,
        encoding: "utf8"
      )
      id = filename.slice(layoutsDir.length).split(".")[0].replace(/^\//, "")
      @layouts[id] = Handlebars.compile(layoutContent)

    @defaultLayout = config.defaultLayout or "default"

    #
    # Templates
    #
    templatesDir  = path.resolve(src, config.templatesDir  || 'templates')
    templatesFiles = glob.sync(path.join(templatesDir, "**/*"))
    @templates = {}

    templatesFiles.forEach (filename) =>
      templateContent = fs.readFileSync(filename,
        encoding: "utf8"
      )
      id = filename.slice(templatesDir.length).split(".")[0].replace(/^\//, "")
      @templates[id] = Handlebars.compile(templateContent)

    @configured = true


  constructor: (@options = {}) ->
    throw(new Error("HandlebarsRenderingEngine is not configured")) unless HandlebarsRenderingEngine.configured

    @layouts = HandlebarsRenderingEngine.layouts
    @templates = HandlebarsRenderingEngine.templates
    @defaultLayout = HandlebarsRenderingEngine.defaultLayout

  render: (content, context, done) ->

    #
    # Context specific helpers
    #
    Handlebars.registerHelper "ifCurrent", (path, options) ->
      if path is context.$current and context.$current.$path
        options.fn this
      else
        options.inverse this

    Handlebars.registerHelper "unlessCurrent", (path, options) ->
      if path isnt context.$current and context.$current.$path
        options.fn this
      else
        options.inverse this

    Handlebars.registerHelper "inspectContext", ->
      require("util").inspect context

    Handlebars.registerHelper "inspect", (obj) ->
      require("util").inspect obj

    parts = {}

    Handlebars.registerHelper "capture", (name, options) ->
      if typeof name isnt "string"
        throw "You have to provide a name to capture helper"
      else
        parts[name] = options.fn this
        ""

    #
    # Resolving template
    #
    template = if @options.template
      @templates[@options.template] or (throw new Error("Unable to find template #{@options.template}"))
    else
      Handlebars.compile(content)
    #
    # Resolving layout
    #
    layoutName = context.$current.$layout or (@options.layout is false) or @options.layout or @defaultLayout
    layoutName = not layoutName if layoutName is true # trick to return layout false when @options.layout is false
    layout = @layouts[layoutName] or (throw new Error("Unable to find layout #{layoutName}"))

    #
    # Rendering content
    #
    body = template(context)


    #
    # Should be used inside the layout to embed the body content or captured fragments
    #
    Handlebars.registerHelper "yield", (name) ->
      if typeof name isnt "string"
        new Handlebars.SafeString(body)
      else
        new Handlebars.SafeString(parts[name] or "")

    #
    # Rendering layout
    #
    result = layout(context)

    done null, result.toString()

module.exports = HandlebarsRenderingEngine
