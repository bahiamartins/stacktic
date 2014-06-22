Controller = require('../lib/Controller')
Route = require('../lib/Route')

describe "Controller", ->
  describe "#route", ->
    it "should add route to provided route map", ->
      routeMap = {}
      context = {}
      controller = new Controller(routeMap, context)
      controller.route("/")
      routeMap["/"].should.be.instanceOf(Route)

    it "should add route having the same globalContext as controller", ->
      routeMap = {}
      context = {}
      controller = new Controller(routeMap, context)
      (controller.route("/").globalContext is context).should.be.true

    it "should bind collections to route", ->
      controller = new Controller({}, {})
      route = controller.route("/", [{}, {}], [{}])
      route.items.size().should.equal(3)
      route.isBound().should.be.true

  describe "#define", ->
    it "should let you alter context", ->
      routeMap = {}
      context = {}

      Controller.define routeMap, context, {}, ->
        @context.a = 1 

      context.should.eql({a: 1})

    it "should let you alter routeMap calling route", ->
      routeMap = {}
      context = {}

      Controller.define routeMap, context, {}, ->
        @route("/")

      routeMap["/"].should.be.instanceOf(Route)
