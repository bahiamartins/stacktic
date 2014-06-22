Route = require('../lib/Route')
Collection = require('../lib/Collection')

createPagesCollection = ->
  new Collection([{ 
      $slug: "home"
      title: "Home Page"
      $content: "<h1>Home Page</h1>" 
    }, 
    { 
      $slug: "about"
      title: "About"
      $content: "<h1>About</h1>" 
    } 
  ])



describe "Route", ->
  describe "#bind", ->
    it "should push items into route items", ->
      pages = createPagesCollection() 
      route = new Route("/:{$slug}")
      route.bind(pages)
      route.items.size().should.equal(pages.size())

    it "should bind path to items", ->
      pages = createPagesCollection() 
      route = new Route("/:{$slug}")
      route.bind(pages)
      route.items.pluck("$path").should.eql(["/home", "/about"])

    it "should throw if an item is not bindable", ->
      (->
        route = new Route("/:{$slug}")
        route.bind([null])
      ).should.throw()

      (->
        route = new Route("/:{$slug}")
        route.bind([(->)])
      ).should.throw()

      (->
        route = new Route("/:{$slug}")
        route.bind([""])
      ).should.throw()


    it "should emit bind:before when item is not bound", ->
      called = false
      pages = createPagesCollection()
      route = new Route("/:{$slug}")
      route.on "bind:before", (item) ->
        called = true
        (item.$path is undefined).should.be.true

      route.bind(pages)
      called.should.be.true

    it "should emit bind:after when item is bound", ->
      called = false
      pages = createPagesCollection()
      route = new Route("/:{$slug}")
      route.on "bind:after", (item) ->
        called = true
        (item.$path is undefined).should.be.false

      route.bind(pages)
      called.should.be.true
      

  describe "#context", ->
    it "should set context function if function is passed", ->
      route = new Route("/")
      fn = ->
      route.context(fn)
      route.contextFn.should.be.Function
      (route.contextFn is fn).should.be.true

    it "should create a function merging object into its invocation context if object is passed", ->  
      route = new Route("/")
      route.context({ a: 1 })
      route.contextFn.should.be.Function
      res = {}
      route.contextFn.call(res)
      res.should.eql({a: 1})


    it "should create a function merging object into its invocation context and interpolating if object is passed and options.interpolate", ->  
      route = new Route("/")
      route.context({ a: ":{a}" }, interpolate: true)
      route.contextFn.should.be.Function
      res = {}
      route.contextFn.call(res, {a: 1})
      res.should.eql({ a: "1" })

  describe "#computeContext", ->
    it "should apply contextFn to passed context", ->
      called = false
      route = new Route("/", {b: 2})
      fn = (item) ->
        called = true
        @a = item.a

      route.context(fn)

      ctx = route.computeContext({a: 1})
      ctx.should.eql({a: 1, b: 2, $current: { a: 1 }, $route: "/", $file: "/index.html", $path: "/"})

      called.should.be.true

    it "should not alter original context", ->
      origCtx = {b: 2}
      route = new Route("/", origCtx)
      route.context ((item) -> @a = item.a)
      ctx = route.computeContext({a: 1})
      origCtx.should.eql({b: 2})

  describe "#isBound", ->
    it "should return true if route is bound to items", ->
      route = new Route("/") 
      route.bind(createPagesCollection())
      route.isBound().should.be.true

    it "should return false unless route is bound to items", ->
      route = new Route("/") 
      route.isBound().should.be.false

  describe "#render", ->
    it "should add renderer", ->
      route = new Route("/") 
      route.render('hbs', {layout: 'home'})
      route.renderers.should.eql([{
        renderer: 'hbs'
        options: {layout: 'home'}
      }])