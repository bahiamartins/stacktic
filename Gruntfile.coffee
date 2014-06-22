module.exports = (grunt) ->
  grunt.initConfig
    clean:
      test: ["test/_fixtures/output"]

    mochaTest:
      test:
        options:
          reporter: "spec"
          require: [
            "coffee-errors"
            "should"
          ]

        src: ["tests/**/*.coffee"]

  grunt.loadNpmTasks "grunt-mocha-test"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.registerTask "default", [
    "clean:test"
    "mochaTest"
  ]
