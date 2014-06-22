Route = require('./Route')

class Controller
  @define = (routes, context, models, fn) ->
    controller = new Controller(routes, context, models)
    fn.call(controller)
    controller = null # no need for a controller object anymore
    true

  constructor: (@routes, @context, @models) ->

  route: (path, collections...) ->
    route = new Route(path, @context)
    for collection in collections
      route.bind(collection)
    @routes[path] = route
    route

module.exports = Controller