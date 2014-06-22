{inspect} = require('util')
Model = require('../lib/Model')
Loaders = require('../lib/Loaders')

warn = console.warn
console.warn = ->

class TestDriver
  constructor: (@options) ->

  load: (done) ->
    done(null, [ { $content: "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Mollitia, voluptas, repellat doloribus sapiente perferendis aliquam autem ducimus sint sed quia aperiam dolorem expedita. Voluptatibus officiis nisi quibusdam! Possimus, libero, consequatur." } ])

loaders = new Loaders()
loaders.registerDriver('test', TestDriver)

describe "Model", ->
  describe "#define", ->
    it "Should reflect subclass right", ->
      Page = Model.define 'Page', ->
      Page.className.should.equal('Page')

    it "Should preserve superclass attributes", ->
      Page = Model.define 'Page', ->
        @validate {}

      Page.className.should.equal('Page')
      Page.validations.length.should.equal(1)
      (Model.className is undefined).should.be.true
      (Model.validations is undefined).should.be.true

  describe "#load", ->
    it "Should load and create items", -> 
      Page = Model.define 'Page', ->
        @dataSource 'test'

      loaders.loadModel Page, ->
        Page.first().should.be.instanceOf(Page)

    it "Should concatenate multiple dataSources", -> 
      Page = Model.define 'Page', ->
        @dataSource 'test'
        @dataSource 'test'

      loaders.loadModel Page, ->
        Page.forEach (page) ->
          page.should.be.instanceOf(Page)
        Page.size().should.equal(2)

  describe "#validate", ->

    it "Should skip with validate skip", ->

      Page = Model.define 'Page', ->
        @dataSource 'test'
        @validate { requiredAttr: {presence: true} }, { invalid: "skip" }

      loaders.loadModel Page, ->
        Page.size().should.equal(0)

    it "Should not skip with validate report", ->

      Page = Model.define 'Page', ->
        @dataSource 'test'
        @validate { requiredAttr: {presence: true} }, { invalid: "report" }

      loaders.loadModel Page, ->
        Page.size().should.equal(1)
        (Page.first().$errors is null).should.be.false

    it "Should throw validating by default", ->

      Page = Model.define 'Page', ->
        @dataSource 'test'
        @validate { requiredAttr: {presence: true} }

      (-> loaders.loadModel(Page)).should.throw()

    it "Should run callback if invalid is fn", ->
      called = false
      Page = Model.define 'Page', ->
        @dataSource 'test'
        @validate { requiredAttr: {presence: true} }, { invalid: -> (called = true) }

      loaders.loadModel Page, ->

      called.should.be.true

    it "Should skip if callback returns false", ->
      Page = Model.define 'Page', ->
        @dataSource 'test'
        @validate { requiredAttr: {presence: true} }, { invalid: -> false }

      loaders.loadModel Page, ->
        Page.size().should.equal(0)

    it "Should not skip if callback returns true", ->
      Page = Model.define 'Page', ->
        @dataSource 'test'
        @validate { requiredAttr: {presence: true} }, { invalid: -> true }

      loaders.loadModel Page, ->
        Page.size().should.equal(1)

  describe "#prototype", ->
    it "Should let you extend prototype", ->

      Page = Model.define 'Page', ->
        @dataSource 'test'
        
        @::countWords = ->
          @$content.split(/\s+/).length

      loaders.loadModel Page, ->
        Page.first().countWords().should.equal(30)


  describe "#callback", ->
    it "Should run load:after callback", ->
      called = false
      Page = Model.define 'Page', ->
        @dataSource 'test'

        @callback 'load:after', (item) ->
          called = true
          item.should.be.instanceOf(Page)
      
      loaders.loadModel Page, ->

      called.should.be.true

    it "Should run validate:before callback", ->
      called = false
      Page = Model.define 'Page', ->
        @dataSource 'test'

        @callback 'validate:before', (item) ->
          called = true
          item.should.be.instanceOf(Page)
      
      loaders.loadModel Page, ->

      called.should.be.true

    it "Should run validate:after callback", ->
      called = false
      Page = Model.define 'Page', ->
        @dataSource 'test'

        @callback 'validate:after', (item) ->
          called = true
          item.should.be.instanceOf(Page)
      
      loaders.loadModel Page, ->

      called.should.be.true


    it "Should run validate:success callback", ->
      called = false
      Page = Model.define 'Page', ->
        @dataSource 'test'

        @callback 'validate:success', (item) ->
          called = true
          item.should.be.instanceOf(Page)
      
      loaders.loadModel Page, ->

      called.should.be.true

    it "Should run validate:error callback", ->
      called = false
      Page = Model.define 'Page', ->
        @dataSource 'test'
        @validate { requiredAttr: {presence: true} }, { invalid: "skip" }
        @callback 'validate:error', (item) ->
          called = true
          item.should.be.instanceOf(Page)
      
      loaders.loadModel Page, ->

      called.should.be.true

    it "Should not run validate:success if error", ->
      called = false
      Page = Model.define 'Page', ->
        @dataSource 'test'
        @validate { requiredAttr: {presence: true} }, { invalid: "skip" }
        @callback 'validate:success', (item) ->
          called = true
          item.should.be.instanceOf(Page)
      
      loaders.loadModel Page, ->

      called.should.be.false

    it "Should not run validate:error if success", ->
      called = false
      Page = Model.define 'Page', ->
        @dataSource 'test'
        @callback 'validate:error', (item) ->
          called = true
          item.should.be.instanceOf(Page)
      
      loaders.loadModel Page, ->

      called.should.be.false

    it "Should run callbacks in the right order", ->
      called = []
      Page = Model.define 'Page', ->
        @dataSource 'test'

        @callback 'load:after', (item) ->
          called.push('load:after')      

        @callback 'validate:before', (item) ->
          called.push('validate:before1')      

        @callback 'validate:before', (item) ->
          called.push('validate:before2')      

        @callback 'validate:success', (item) ->
          called.push('validate:success')      

        @callback 'validate:after', (item) ->
          called.push('validate:after')      

      loaders.loadModel Page, ->

      called.should.eql(['load:after', 'validate:before1', 'validate:before2', 'validate:success', 'validate:after'])
