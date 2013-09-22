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
    stylus:
      all:
        expand: true
        dest: 'css/'
        src: ['src/*.styl']
        ext: '.css'
        flatten: true
    watch:
      coffee:
        files: ['src/*.coffee'] # can't be reference due to rewriting
        tasks: ['coffee']
        options: spawn: false # needed for event games to work
      stylus:
        files: ['src/*.styl']
        tasks: ['stylus']
        options: spawn: false

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  
  grunt.registerTask 'default', ['coffee', 'stylus']

  grunt.event.on 'watch', (action, file) ->
    grunt.config.set 'coffee.all.src', [ file ] if /\.coffee/.test file
    grunt.config.set 'coffee.all.src', [ file ] if /\.coffee/.test file
