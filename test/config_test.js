var Config     = require('../lib/config');

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

describe('Config', function(){
  describe('#get', function(){
    it('should return the right value', function(){
      conf.get('stacktic.example_3.plugins.stacktic-yfm-ds.base').should.equal('pages');
    });
  });
});