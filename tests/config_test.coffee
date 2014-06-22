Config = require("../lib/config")

conf = new Config(
  {
    key1: {
      key2: "value"
      key3: null
    }
  }
)

describe "Config", ->
  describe "#get", ->
    it "should return the right value", ->
      conf.get("key1.key2").should.equal "value"

    it "should return null if key is missing and default is not provided", ->
      (conf.get("undefined1.undefined2.undefined3") is null).should.be.true

    it "should return default if key is missing and default present", ->
      conf.get("undefined1.undefined2.undefined3", "default").should.equal "default"

    it "should return default if key is null and default present", ->
      conf.get("key1.key3", "default").should.equal "default"

  describe "#set", ->
    it "should be chainable", ->
      conf.set("key1.key4", "newValue").should.be.instanceOf(Config)

    it "should set the right value", ->
      conf.set("key1.key5", "newValue").get("key1.key5").should.equal "newValue"

    it "should create containing objects if they not exists", ->
      (->
        conf.set("undef.undef.undef.key7", "newValue").get("undef.undef.undef.key7").should.equal "newValue"
      ).should.not.throw
      
    it "should return null if key is missing and default is not provided", ->
      (conf.get("undefined1.undefined2.undefined3") is null).should.be.true

    it "should return default if key is missing and default present", ->
      conf.get("undefined1.undefined2.undefined3", "default").should.equal "default"

    it "should return default if key is null and default present", ->
      conf.get("key1.key3", "default").should.equal "default"





