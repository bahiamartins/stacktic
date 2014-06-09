var _     = require('lodash'),
path      = require('path'),
util      = require('util'),
events    = require('events'),
url       = require('url'),
Log       = require('grunt-legacy-log').Log,
async     = require('async'),
Config    = require('./config'),
collection= require('./collection');

/*===============================
=            Private            =
===============================*/

var anonControllersCount = 0;

function runController(instance, name) {
  var fn = instance.controllers[name];
  var pluginOpts = (typeof name === 'string') ? instance.config.get("controllers." + name, {}) : {};
  fn.call(null, instance, new Config(pluginOpts));
}

function runControllers(instance) {
  _.forOwn(instance.controllers, function(controller, name) {
    runController(instance, name);
  });
}

function interpolatePath(path, item) {
  return _.template(path, item);
}

function load(instance) {
  var collections = instance.config.get('collections', {}),
  toComplete = _.keys(collections).length;

  instance.context.collections = instance.context.collections ? instance.context.collections : {};

  instance.verbose.writeln('[Stacktic] Loading data for ' + toComplete + ' collections ...');


  if( toComplete === 0 ) {
    instance.verbose.writeln('[Stacktic] All collections loaded.. emitting load event');
    instance.emit('load', instance.context.collections);
  }

  _.forOwn(collections, function(uri, name) {
    var parsedUrl   = url.parse(uri),
    protocol        = parsedUrl.protocol,
    context         = instance.context,
    ds              = instance.getDataSource(protocol);

    if (!ds) {
      throw( new Error("DataSource not found for uri: '" + uri + "'") );
    }

    ds.load(parsedUrl, function(err, data){
      data = data || [];
      instance.verbose.writeln('[Stacktic] Loaded data for ' + name + ' collection containing ' + data.length + ' objects');

      _.each(data, function(item){
        instance.emit('load.item', item, name, uri);
      });
      context.collections[name] = collection(data);
      instance.emit('load.collection', name, data);

      toComplete--;

      if( toComplete === 0 ) {
        instance.verbose.ok('[Stacktic] All collections loaded ..emitting load event');
        instance.emit('load', instance.context.collections);
      }
    });

  });
}

function buildItemContext(instance, route, item) {
  var ctx = {
    global: instance.context,
    current: item,
    route: route
  };

  return ctx;
}

function applyRenderers(instance, route, item, renderers){
  var context = buildItemContext(instance, route, item),
      
      functions = _.map(renderers, function(renderer){
        var adapted = function(content, cb){
          var fn = _.isFunction(renderer) ? renderer : instance.renderers[renderer];
          if (! fn) {
            throw( new Error("Unable to find '" + renderer + "' renderer") );
          }
          fn(content, context, cb);
        };
        return adapted;
      }),
      
      renderFn = async.compose.apply(async, functions);

  renderFn(item._content || "", function(err, content){
    instance.verbose.ok('[Stacktic] Rendering done for "' + item.path + '" ..emitting rendered event');
    instance.emit('rendered', route, item, content);
  });
}

function render(instance) {
  var defaultRenderers = (instance.config.get('renderers') || []).map(function(name){
    var fn = instance.renderers[name];
    if (! fn) {
      throw( new Error("Unable to find '" + name + "' renderer") );
    }
    return fn;
  });

  _.forEach(_.values(instance.routes), function(route){
    route.items.forEach(function(item){
      applyRenderers(instance, route, item, route.renderers || defaultRenderers);
    });
  });
}


function applyWriters(instance, route, item, content){
  var writers = (instance.config.get('writers') || []);
  var toComplete = writers.length;
  
  if( toComplete === 0 ) {
    instance.emit('written', route, item, "[NULL WRITER]");
    return;
  }
  
  writers.forEach(function(name){
    var fn = instance.writers[name];

    if (! fn) {
      throw( new Error("Unable to find '" + name + "' writer in [" + _.keys(instance.writers).join(', ') + "]") );
    }

    fn(route, item, content, function(){
      toComplete--;
      if( toComplete === 0 ) {
        instance.emit('written', route, item, name);
      }
    });
  });
}



/*==============================
=            Public            =
==============================*/


function Stacktic() {
  events.EventEmitter.call(this);
  this.log = new Log();
  this.verbose = this.log.verbose;
  this.config = new Config({});
  this.context = new Config({});
  this.context.config = this.config;
  this.controllers = {};
  this.routes = {};
  this.dataSources = {};
  this.writers = {};
  this.renderers = {};
}

util.inherits(Stacktic, events.EventEmitter);

Stacktic.getInstance = function(){
  return Stacktic.instance = Stacktic.instance || new Stacktic();
};

Stacktic.prototype.use   = function(name, fn) {
  var isAnon = !fn;

  fn = fn || name;

  if (typeof fn !== 'function') {
    fn = require(path.resolve(process.cwd(), fn));
  }

  var pluginOpts = (!isAnon) ? this.config.get("plugins." + name, {}) : {};

  fn.call(null, this, new Config(pluginOpts));

  return this;
};

Stacktic.prototype.controller = function(name, fn) {
  var isAnon = !fn;

  fn = fn || name;

  if (typeof fn !== 'function') {
    fn = require(path.resolve(process.cwd(), fn));
  }

  this.controllers[isAnon ? '_anonymous.' + anonControllersCount++ : name] = fn; 
  return this;
};

Stacktic.prototype.putDataSource = function(protocol, object) {
  var normalizedProtocol = protocol.match(/:$/) ? protocol : (protocol + ":");
  this.dataSources[normalizedProtocol] = object;
  return this;
};

Stacktic.prototype.getDataSource  = function(protocol) {
  var normalizedProtocol = protocol.match(/:$/) ? protocol : (protocol + ":");
  return this.dataSources[normalizedProtocol];
};


Stacktic.prototype.putRenderer = function(name, fn) {
  this.renderers[name] = fn;
  return this;
};

Stacktic.prototype.putWriter = function(name, fn) {
  this.writers[name] = fn;
  return this;
};

Stacktic.prototype.configure  = function(config) {
  _.merge(this.config, config);
  _.merge(this.log.options, this.config.get('logger', {}));
  return this;
};

Stacktic.prototype.route = function(path, items, opts) {
  opts = opts || {};
  
  if (_.isString(items)) {
    items = this.context.get(items, []);
  }

  var filePath = path.match(/\/$/) ? path + "index.html" : (
      path.match(/\./) ? path : path + ".html"
  );

  this.routes[path] = {
    items: _.map(items.toArray(), function(item){
      item.path = interpolatePath(path, item);
      item.file = interpolatePath(filePath, item);
      return item;
    }),
    options: opts,
    renderers: (_.isArray(opts.render) || !opts.render) ? opts.render : [opts.render]
  };

  return this;
};

Stacktic.prototype.build  = function() {
  var instance = this, 
  toComplete = 0;  
  instance.log.header('[Stacktic] Start building ...');

  instance.on('written', function(route, item, writer) {
    instance.verbose.writeln('[Stacktic:' + writer + '] written "' + item.path + '"');
    toComplete--;
    if (toComplete === 0) {
      instance.log.ok('[Stacktic] Building complete.');
      instance.emit('done');
    }
  });

  instance.on('rendered', function(route, item, content){
    instance.verbose.writeln('[Stacktic] Handling rendered event for "' + item.path + '"');
    applyWriters(instance, route, item, content);
  });

  instance.on('load', function(){
    instance.verbose.writeln('[Stacktic] Handling load event');

    instance.verbose.writeln('[Stacktic] Running controllers');
    runControllers(instance);


    toComplete = _.reduce(_.values(instance.routes), function(res, route){
      return res + route.items.length;
    }, 0);

    instance.verbose.ok('[Stacktic] Controllers loaded: ' + toComplete + ' objects to render');

    render(instance);
  });

  instance.emit('start');
  load(instance);
};

module.exports = Stacktic.getInstance();