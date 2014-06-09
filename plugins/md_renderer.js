var marked = require('marked'),
    highlightJs = require('highlight.js'),
    _ = require('lodash');

module.exports = function(stacktic) {
  stacktic.putRenderer('md', function(content, context, fn){
    var config = stacktic.config.get('plugins.md', {}),
        options = {
          highlight: function (code) {
            return highlightJs.highlightAuto(code).value;
          }
        };
    _.merge(options, config);
    marked.setOptions(options);

    fn(null, marked(content));
  });
};