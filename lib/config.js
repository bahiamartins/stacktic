var _ = require("lodash");

function process(obj, key, create){
  
  // console.log('process', obj, key);

  var keys = key.split('.'),
      res = { 
        object: obj,
        propname: keys.pop()
      };

  for (var i = 0; i < keys.length; i++) {
      var k = keys[i];
    
    if(res.object[k] == null) {
      if (create === true) {
        if (i < keys.length - 1) { 
          res.object[k] = {};
        }
      } else {
        res.object = {};
        res.propname = null;
        return res;
      }
    }

    res.object = res.object[k];
    // console.log('res', i, "-" , res);
  };

  return res;
}

function Config(obj) {
  _.merge(this, obj);
};

Config.prototype.get = function(path, def){
  var ret = process(this, path);
  var res = ret.propname == '' ? ret.object : ret.object[ret.propname];
  return (def && (res === null || res === undefined)) ? def : res;
};

Config.prototype.set = function(path, value) {
  var ret = process(this, path, true);
  return (ret.object[ret.propname] = value);
};

module.exports = Config;


