var fs        = require('fs'),
    path      = require('path'),
    mkdirp    = require('mkdirp');

module.exports = function(stacktic) {
  stacktic.putWriter('fs', function(route, item, content, fn){
    var configDest = stacktic.config.get('plugins.fs.dest'),
        dest       = ( configDest ? path.resolve(process.cwd(), configDest) : process.cwd() ),
        destFile   = path.join(dest, item.file);

    stacktic.verbose.writeln( '[Stacktic:fs] writing "' + item.path + '" to "' + destFile + '"' );

    mkdirp.sync(path.dirname(destFile));
    fs.writeFileSync(destFile, content, 'utf-8');

    fn(null);
  });
};