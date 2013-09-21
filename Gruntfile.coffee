# jshint camelcase: false
'use strict'
mountFolder = (connect, dir) ->
  connect.static require('path').resolve(dir)

## Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'

module.exports = (grunt) ->
  # show elapsed time at the end
  require('time-grunt') grunt
  # load all grunt tasks
  require('load-grunt-tasks') grunt

  # configurable paths
  yeomanConfig =
    app: 'app'
    dist: 'dist'

  grunt.initConfig
    yeoman: yeomanConfig
    watch:
      options:
        spawn: true
        atBegin: true
      jade:
        files: ['<%= yeoman.app %>/{,*/}*.jade']
        tasks: ['jade:dist', 'htmlmin', 'usemin']
      coffee:
        files: ['<%= yeoman.app %>/scripts/{,*/}*.coffee']
        tasks: ['coffee:dist']
      coffeeTest:
        files: ['test/spec/{,*/}*.coffee']
        tasks: ['coffee:test']
      compass:
        files: ['<%= yeoman.app %>/styles/{,*/}*.{scss,sass}']
        tasks: ['compass:server']
      manifest:
        files: ['<%= yeoman.app %>/manifest.json']
        tasks: ['copy:watch']
      # watch end

    connect:
      options:
        port: 9000
        # change this to '0.0.0.0' to access the server from outside
        hostname: 'localhost'
      test:
        options:
          middleware: (connect) ->
            [
              mountFolder connect, '.tmp'
              mountFolder connect, 'test'
            ]
      # connect end

    clean:
      dist:
        files: [
          dot: true
          src: [
            '.tmp'
            '<%= yeoman.app %>/{,*/}*.html'
            '<%= yeoman.app %>/scripts/{,*/}*.js'
            '<%= yeoman.dist %>/*'
            '!<%= yeoman.dist %>/.git*'
          ]
        ]
      server: '.tmp'
      # clean end

    jade:
      dist:
        options:
          pretty: true
        files: [
          expand: true
          cwd: '<%= yeoman.app %>'
          dest: '.tmp'
          src: '{,*/}*.jade'
          ext: '.html'
        ]
      # jade end

    jshint:
      options:
        jshintrc: '.jshintrc'
      all: [ 'test/spec/{,*/}*.js' ]
      # jshint end

    mocha:
      all:
        options:
          run: true
          urls: ['http://localhost:<%= connect.options.port %>/index.html']
      # mocha end

    coffee:
      dist:
        files: [
          expand: true
          cwd: '<%= yeoman.app %>/scripts'
          src: '{,*/}*.coffee'
          dest: '.tmp/scripts'
          ext: '.js'
        ]
      test:
        files: [
          expand: true
          cwd: 'test/spec'
          src: '{,*/}*.coffee'
          dest: '.tmp/spec'
          ext: '.js'
        ]
      # coffee end

    compass:
      options:
        sassDir: '<%= yeoman.app %>/styles'
        cssDir: '.tmp/styles'
        generatedImagesDir: '.tmp/images/generated'
        imagesDir: '<%= yeoman.app %>/images'
        javascriptsDir: '<%= yeoman.app %>/scripts'
        fontsDir: '<%= yeoman.app %>/styles/fonts'
        importPath: '<%= yeoman.app %>/bower_components'
        httpImagesPath: '/images'
        httpGeneratedImagesPath: '/images/generated'
        httpFontsPath: '/styles/fonts'
        relativeAssets: false
      dist: {}
      server:
        options:
          debugInfo: true
      # compass end

    # not used since Uglify task does concat,
    # but still available if needed
    concat:
      dist:
        files: [
          '<%= yeoman.dist %>/scripts/background.js': [
            '.tmp/scripts/background.js'
          ]
        ]

    # not enabled since usemin task does concat and uglify
    # check index.html to edit your build targets
    # enable this task if you prefer defining your build targets here
    uglify:
      dist:
        files: [
          '<%= yeoman.dist %>/scripts/background.js': [
            '<%= yeoman.dist %>/scripts/background.js'
          ]
        ]

    useminPrepare:
      options:
        dest: '<%= yeoman.dist %>'
      html: ['.tmp/index.html']

    usemin:
      options:
        dirs: ['<%= yeoman.dist %>']
      html: ['<%= yeoman.dist %>/{,*/}*.html']
      css: ['<%= yeoman.dist %>/styles/{,*/}*.css']

    imagemin:
      dist:
        files: [
          expand: true
          cwd: '<%= yeoman.app %>/images'
          src: '{,*/}*.{png,jpg,jpeg}'
          dest: '<%= yeoman.dist %>/images'
        ]

    svgmin:
      dist:
        files: [
          expand: true
          cwd: '<%= yeoman.app %>/images'
          src: '{,*/}*.svg'
          dest: '<%= yeoman.dist %>/images'
        ]

    cssmin:
      dist:
        files:
          '<%= yeoman.dist %>/styles/main.css': [
            '.tmp/styles/{,*/}*.css'
            '<%= yeoman.app %>/styles/{,*/}*.css'
          ]

    htmlmin:
      dist:
        # options:
          # removeCommentsFromCDATA: true
          ## https://github.com/yeoman/grunt-usemin/issues/44
          # collapseWhitespace: true
          # collapseBooleanAttributes: true
          # removeAttributeQuotes: true
          # removeRedundantAttributes: true
          # useShortDoctype: true
          # removeEmptyAttributes: true
          # removeOptionalTags: true
        files: [
          expand: true
          cwd: '.tmp'
          src: [
            '*.html'
            'views/*.html'
          ]
          dest: '<%= yeoman.dist %>'
        ]
      # htmlmin end
    # Put files not handled in other tasks here
    copy:
      dist:
        files: [
          expand: true
          dot: true
          cwd: '<%= yeoman.app %>'
          dest: '<%= yeoman.dist %>'
          src: [
            '*.{ico,png,txt}'
            'images/{,*/}*.{webp,gif}'
            '_locales/{,*/}*.json'
            'styles/fonts/*'
            'manifest.json'
          ]
        ,
          expand: true
          cwd: '.tmp/images'
          dest: '<%= yeoman.dist %>/images'
          src: [ 'generated/*' ]
        ]
      watch:
        files: [
          expand: true
          dot: true
          cwd: '<%= yeoman.app %>'
          dest: '<%= yeoman.dist %>'
          src: ['manifest.json']
        ]

    concurrent:
      server: [
        'coffee:dist'
        'compass:server'
      ]
      test: [
        'coffee'
        'compass'
      ]
      dist: [
        'coffee:dist'
        'compass:dist'
        'imagemin'
        'svgmin'
        'htmlmin'
      ]

    compress:
      dist:
        options:
          archive: 'package/chrome robot.zip'
        files: [
          expand: true
          cwd: 'dist/'
          src: ['**']
          dest: ''
        ]

    ngmin:
      dist:
        files: [
          expand: true
          cwd: '<%= yeoman.dist %>/scripts'
          src: '{,*/}*.js'
          dest: '<%= yeoman.dist %>/scripts'
        ]

  grunt.registerTask 'test', [
    'clean:server'
    'concurrent:test'
    'connect:test'
    'mocha'
  ]

  grunt.registerTask 'build', [
    'clean:dist'
    'jade:dist'
    'useminPrepare'
    'concurrent:dist'
    'cssmin'
    'concat'
    'ngmin'
    'uglify'
    'copy:dist'
    'usemin'
    'compress'
  ]

  grunt.registerTask 'default', [
    'jshint'
    'test'
    'build'
  ]

  # end
