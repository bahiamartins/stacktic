module.exports = function(grunt) {
  grunt.initConfig({
    clean: {
      test: ["test/_output"]
    }
    mochaTest: {
      test: {
        options: {
          reporter: 'spec',
          require: [
            'should'
          ]
        },
        src: ['test/**/*.js']
      }
    },

    jshint: {
      src: ['lib/**/*.js', 'test/**/*.js', 'plugins/**/*.js'],
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        unused: true,
        boss: true,
        eqnull: true,
        browser: true,
        globals: {
          console: true,
          require: true,
          define: true,
          requirejs: true,
          describe: true,
          expect: true,
          it: true,
          module: true,
          process: true,
          JSON: true
        }
      }
    },

    connect: {
      test: {
        options: {
          base: ['test/_output'],
          keepalive: true
        }      
      }
    }
  });




  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-mocha-test');
  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.registerTask('default', ['jshint', 'mochaTest']);

}