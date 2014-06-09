var Handlebars = require('handlebars'),
          fs   = require('fs'),
          glob = require('glob'),
          path = require('path');

module.exports = function(stacktic) {
  stacktic.Handlebars = Handlebars;
  var config = {}, 
      layouts = {};
  
  stacktic.on('start', function(){
    config = stacktic.config.get('plugins.hbs', config);
    var partialsDir = path.resolve(process.cwd(), config.partialsDir || 'partials'),
        layoutsDir  = path.resolve(process.cwd(), config.layoutsDir  || 'layouts'),
        partials = glob.sync(path.join(partialsDir, "**/*"));
    
    partials.forEach(function(filename){
      var partialContent = fs.readFileSync(filename),
      id = filename.slice(partialsDir.length).split('.')[0];
      Handlebars.registerPartial(id, partialContent);
    });

    layouts  = glob.sync(path.join(layoutsDir, "**/*"));
    layouts['default'] = Handlebars.compile('{{{yield}}}');

    layouts.forEach(function(filename){
      var layoutContent = fs.readFileSync(filename, {encoding: 'utf8'}),
      id = filename.slice(partialsDir.length).split('.')[0];
      layouts[id] = Handlebars.compile(layoutContent);
    });
    
    config.defaultLayout = config.defaultLayout || 'default';
  });

  stacktic.putRenderer('hbs', function(content, context, fn){
    var template = Handlebars.compile(content),
        body = template(context),
        layoutName = context.current.layout || context.route.options.layout || config.defaultLayout,
        layout = layouts[layoutName];

    if (! layout) {
      throw( new  Error('Unable to find layout "' + layoutName + '"') );
    }

    context.yield = body;

    fn(null, layout(context));
  });
};