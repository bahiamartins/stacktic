var Config = require('../lib/config');

var conf = new Config({
  stacktic: {
    example_3: {
      plugins: {
        'stacktic-yfm-ds' : {
          base: "pages" 
        },
        'stacktic-handlebars': { extname: '.hbs' }
      },
      
      dest: '_output',
      controllers: [ 'main.js' ]
    }
  }
});

console.log(conf.get('stacktic.example_3.plugins.stacktic-yfm-ds'))
