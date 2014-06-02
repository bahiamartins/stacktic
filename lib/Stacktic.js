var _     = require('lodash'),
path      = require('path'),
util      = require('util'),
fs        = require('fs'),
mkdirp    = require('mkdirp'),
events    = require('events'),
Config    = require('./config');
DataStore = require('./DataStore');

function Stacktic(config) {
  events.EventEmitter.call(this);

  this.config = new Config(config || {});
  this.config.dest = this.config.dest ? path.resolve(process.cwd(), this.config.dest) : process.cwd();
  this.routes = {};
  this.ds = {};

};

util.inherits(Stacktic, events.EventEmitter);

Stacktic.prototype.route = function(route, name, fn) {
  this.routes[route] = {
    name: name, 
    fn: fn
  };
};

Stacktic.prototype.addDataStore = function(name, object) {
  _.merge(this.ds[name] = new DataStore(), object);
};

Stacktic.prototype.use   = function(name, fn) {
  fn = fn || name;

  if (typeof fn !== 'function') {
    fn = require(path.resolve(process.cwd(), fn));
  }

  var pluginOpts = (typeof name === 'string') ? this.config.get("plugins." + name, {}) : {};

  fn.call(null, this, new Config(pluginOpts));
};

Stacktic.prototype.build = function() {
  var dest = this.config.get('dest');
  _.forOwn(this.routes, function(routeObj, routePath){
    var filePath = routePath.match(/\/$/) ? routePath + "index.html" : routePath,
    destFile = path.join(dest, filePath);

    routeObj.fn(function(data){
      mkdirp.sync(path.dirname(destFile));
      fs.writeFileSync(destFile, data, 'utf-8');
    });
  });
};

module.exports = Stacktic;