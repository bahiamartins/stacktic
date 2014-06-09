var instance = require('./lib/stacktic');

instance.use(require('./plugins/fs_writer'))
.use(require('./plugins/yfm_datasource'))
.use(require('./plugins/lodash_renderer'))
.use(require('./plugins/md_renderer'))
.use(require('./plugins/hbs_renderer'));

instance.config.set('renderers', ['hbs', 'md']);
instance.config.set('writers', ['fs']);

module.exports = instance;