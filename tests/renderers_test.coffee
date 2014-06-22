Renderers = require('../lib/Renderers')
HandlebarsRenderingEngine = require('../plugins/hbs/HandlebarsRenderingEngine')

HandlebarsRenderingEngine.configure({src: 'tests/_fixtures'}, {})

class GreeterRenderer
  render: (content, context, done) ->
    done(null, "Hi #{content}")

describe "Renderers", ->
  describe "#registerEngine", ->
    it "should register an engine", ->
      renderers = new Renderers()
      renderers.registerEngine('hbs', HandlebarsRenderingEngine)
      (renderers.engines.hbs is HandlebarsRenderingEngine).should.be.true

  describe "#resolveEngine", ->
    it "should instantiate an engine if exists", ->
      instanceOptions = {a: 1}
      renderers = new Renderers()
      renderers.registerEngine('hbs', HandlebarsRenderingEngine)
      eng = renderers.resolveEngine('hbs', instanceOptions)
      eng.should.be.instanceOf(HandlebarsRenderingEngine)

  describe "#setDefaultEngines", ->
    it "should setup default engines", ->
      renderers = new Renderers()
      renderers.setDefaultEngines(['hbs', 'md'], {hbs: {layout: 'app'}})
      renderers.defaultEngines.should.eql([
        {renderer: 'hbs', options: {layout: 'app'}}
        {renderer: 'md', options: {}}
      ])

    it "should not throw if no options are provided", ->
      renderers = new Renderers()
      (->
        renderers.setDefaultEngines(['hbs', 'md'])
      ).should.not.throw()

  describe "#render", ->
    it 'should render renderables', ->
      called = false
      renderables = [{
        a: 1,
        $renderers: [{renderer: 'hbs', options: {}}]
        $current:
          $content: "{{a}}"
      }]

      renderers = new Renderers()
      renderers.registerEngine('hbs', HandlebarsRenderingEngine)
      renderers.render renderables, (err, objects, x) ->
        called = true
        objects.should.be.an.Array
        objects[0].$rendered.should.equal('1')
      called.should.be.true


    it 'should render many renderables', ->
      called = false
      renderables = [{
        a: 1,
        $renderers: [{renderer: 'hbs', options: {}}]
        $current:
          $content: "{{a}}"
      },
      {
        a: 2,
        $renderers: [{renderer: 'hbs', options: {}}]
        $current:
          $content: "{{a}}"
      }]

      renderers = new Renderers()
      renderers.registerEngine('hbs', HandlebarsRenderingEngine)
      renderers.render renderables, (err, objects, x) ->
        called = true
        objects.should.be.an.Array
        objects.length.should.equal(2)
        objects[1].$rendered.should.equal('2')
      
      called.should.be.true


    it 'should compose engines', ->
      called = false
      renderables = [{
        name: "Alice"
        $renderers: [{renderer: 'hbs', options: {}}]
        $current:
          $content: "{{name}}"
      },
      {
        name: "Bob"
        $renderers: [{renderer: 'hbs', options: {}}, {renderer: 'greeter', options: {}}]
        $current:
          $content: "{{name}}"
      }]

      renderers = new Renderers()
      renderers.registerEngine('hbs', HandlebarsRenderingEngine)
      renderers.registerEngine('greeter', GreeterRenderer)
      renderers.render renderables, (err, objects, x) ->
        called = true
        objects.should.be.an.Array
        objects.length.should.equal(2)
        objects[0].$rendered.should.equal('Alice')
        objects[1].$rendered.should.equal('Hi Bob')
      
      called.should.be.true
