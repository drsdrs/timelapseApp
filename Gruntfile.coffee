module.exports = (grunt) ->
  grunt.initConfig

    express:
      options:
        opts: ['node_modules/coffee-script/bin/coffee']
      dev:
        options:
          script: './server.coffee'

    coffeelint:
      files: [
        "Gruntfile.coffee"
        "server.coffee"
        "app/coffee/**/*.coffee"
      ]

    coffee:
      all:
        files: [
          'app/app.js': "app/coffee/**/*.coffee"
        ]
        options:
          join: true

    watch:
      lint:
        files: ["<%= coffeelint.files %>"]
        tasks: ["coffeelint"]
      coffee:
        files: ["app/coffee/**/*.coffee"]
        tasks: ["coffee"]
      express:
        files: ["server.coffee", "helper/*.coffee"]
        tasks:  [ 'express' ]
        options:
          spawn: false

  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-express-server"

  grunt.registerTask "default", ["coffeelint"]
  grunt.registerTask "server", ["server"]

  grunt.registerTask "go", ["express","coffeelint", "coffee", "watch"]

