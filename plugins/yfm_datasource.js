var
yfm = require('yfm'),
fs   = require('fs'),
path = require('path'),
glob = require('glob');

module.exports = function(stacktic){
  stacktic.putDataSource('yfm', {
    load: function(data, cb){
      var base = stacktic.config.get('plugins.yfm.base') || process.cwd();
      var res  = (glob.sync(path.join(base, data.path), { nonull: false }) || [])
                  
          .map(function(file){
            if (fs.lstatSync(file).isFile()) {
              var parsed = yfm.read(file),
                  res = parsed.context || {};
              res._content = parsed.content;
              res._id = file.slice(base.length);
              return res;
            }
          })
          
          .filter(function(obj){
              return obj != null;
          });

      cb(null, res);
    }
  });
};