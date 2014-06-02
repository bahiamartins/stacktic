var Handlebars = require('handlebars');
var marked = require('marked');
var slug = require('slug');

marked.setOptions({
  renderer: new marked.Renderer(),
  gfm: true,
  tables: true,
  breaks: false,
  pedantic: false,
  sanitize: true,
  smartLists: true,
  smartypants: false,
  highlight: function (code) {
    return require('highlight.js').highlightAuto(code).value;
  }
});

var Stacktic = require('..'),
    _ = require('lodash'),
    path = require('path'),
    stacktic = new Stacktic({
      dest: '_output',
      plugins: {
        'yfm' : {
          base: path.resolve(__dirname, "_fake")
        }
      }
    });

stacktic.use('yfm', require('../lib/stores/YfmDataStore'));

stacktic.use('slug', function(stacktic, config){
  stacktic.on('model.load', function(model){
    var fn = config.get('param', function(model){ return model.title;}),
        dest = config.get('propname', 'slug'); 
    
    model[dest] = slug(fn(model), config.get('sep', '-')).toLowerCase();
    
    console.log(model);
  });
});

stacktic.use(function(stacktic, config){
  stacktic.route('/', 'home', function(render){
    stacktic.ds.yfm.first('pages/home.md', function(err, page){
      var template = Handlebars.compile(marked(page._content));
      render(template(page));
    });
  });
});

stacktic.build();




