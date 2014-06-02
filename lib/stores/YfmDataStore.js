var
yfm = require('yfm'),
fs   = require('fs'),
path = require('path'),
glob = require('glob');

module.exports = function(stacktic, config){
  config.base = config.base || process.cwd();
  stacktic.addDataStore('yfm', {
    get: function(id, cb){  
      var res  = (glob.sync(path.join(config.base, id), { nonull: false }) || [])
                  
          .map(function(file){

            if (fs.lstatSync(file).isFile()) {
              var parsed = yfm.read(file),
                  res = parsed.context || {};
              
              res._content = parsed.content;
              res._id = file.slice(config.base.length);

              stacktic.emit('model.load', res);
              return res;
            };

          })
          
          .filter(function(obj){
              return obj != null;
          });

      cb(null, res);
    }
  });
};

