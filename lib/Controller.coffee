Route = require('./Route')

argumentNames = (fun) ->
  names = fun.toString().match(/^[\s\(]*function[^(]*\(([^)]*)\)/)[1].replace(/\/\/.*?[\r\n]|\/\*(?:.|[\r\n])*?\*\//g, "").replace(/\s+/g, "").split(",")
  (if names.length is 1 and not names[0] then [] else names)

class Controller
  @define = (routes, context, models, fn) ->
    controller = new Controller(routes, context, models)
    args = argumentNames(fn).map (name) ->
      if model = models[name]
        model
      else if name is 'route'
        controller.route
      else if name is 'context'
        context

    fn.apply(controller, args)
    controller = null # no need for a controller object anymore
    true

  constructor: (@routes, @context, @models) ->

  route: (path, collections...) =>
    route = new Route(path, @context)
    for collection in collections
      route.bind(collection)
    @routes[path] = route
    route

module.exports = Controller
