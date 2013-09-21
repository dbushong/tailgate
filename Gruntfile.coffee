module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      all:
        options:
          sourceMap: true
        expand: true
        dest: 'js/'
        src: ['src/*.coffee']
        ext: '.js'
        flatten: true

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  
  grunt.registerTask 'default', ['coffee']
