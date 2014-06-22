cssmin = require("cssmin")

class Renderer
  render: (content, context, done) ->
    done null, cssmin(content)

module.exports = Renderer