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
    watch:
      coffee:
        files: ['<%= coffee.all.src %>']
        tasks: ['coffee']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  
  grunt.registerTask 'default', ['coffee']

  grunt.event.on 'watch', (action, file) ->
    grunt.config ['coffee', 'all', 'src'], [file]
