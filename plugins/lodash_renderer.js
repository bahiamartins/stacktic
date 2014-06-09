var _ = require('lodash');

module.exports = function(stacktic) {
  stacktic.putRenderer('lodash', function(content, context, fn){
    fn(null, _.template(content || "", context));
  });
};