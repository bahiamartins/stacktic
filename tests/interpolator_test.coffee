Interpolator = require('../lib/Interpolator')

describe "Interpolator", ->
  describe "#interpolate", ->
    it "Should interpolate with default delimiters", ->
      interpolator = new Interpolator()
      interpolator.interpolate('<%= x %>', {x: 5}).should.equal('5')

    it "Should interpolate with custom delimiters", ->
      interpolator = new Interpolator(/\{\{([\s\S]+?)\}\}/g)
      interpolator.interpolate('{{ x }}', {x: 5}).should.equal('5')

    it "Should not escape with lodash default delimiters", ->
      interpolator = new Interpolator()
      interpolator.interpolate('<%- x %>', {x: 5}).should.equal('<%- x %>')

    it "Should not eval with lodash default delimiters", ->
      interpolator = new Interpolator()
      interpolator.interpolate('<% x %>', {x: 5}).should.equal('<% x %>')

  describe "#interpolateObject", ->
    it "Should interpolate string in objects", ->
      interpolator = new Interpolator()
      object =
        props:
          a: "<%= a %>"
          b: "<%= b %>"
          c: [
            "<%= a %>"
            "<%= b %>"
          ]

      interpolator.interpolateObject(object, {a: 1, b: 2})

      object.should.eql({
        props:
          a: "1"
          b: "2"
          c: [
            "1"
            "2"
          ]
        })

  it "Should interpolate with custom delimiters", ->
    interpolator = new Interpolator(/\:\{([\s\S]+?)}/g)

    data = { 
      '$slug': 'home'
      title: 'Home Page'
      '$content': '<h1>Home Page</h1>'
      '$path': '/home' 
    }
    
    object = {
      title: ":{title}"
    }

    interpolator.interpolateObject(object, data)

    object.should.eql({
      title: 'Home Page'
    })