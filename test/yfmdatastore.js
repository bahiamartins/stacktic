var 
path = require('path'),
Stacktic = require('..'),
Config = require('../lib/config'),
yfmDs = require('../lib/stores/YfmDataStore'),
stacktic = new Stacktic({
  plugins: {
    'yfm' : {
      base: path.resolve(__dirname, "_fake/pages")
    }
  }
});

stacktic.use('yfm', yfmDs);

stacktic.ds.yfm.get('/home.md', function(err, data){
  console.log(data);
});