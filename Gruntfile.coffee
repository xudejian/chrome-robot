'use strict'
LIVERELOAD_PORT = 35729
lrSnippet = require('connect-livereload') port: LIVERELOAD_PORT
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
    cmp: 'app'

  try
    yeomanConfig.app = require('./bower.json').appPath || yeomanConfig.app
  catch e

  grunt.initConfig
    yeoman: yeomanConfig
    watch:
      options:
        atBegin: true
        livereload: LIVERELOAD_PORT
        spawn: false
      jade:
        files: ['<%= yeoman.app %>/{,views/**/}*.jade']
        tasks: ['jade:dist']
      jadeTest:
        files: ['test/test.jade']
        tasks: ['jade:test']
      coffee:
        files: ['<%= yeoman.app %>/scripts/**/*.coffee']
        tasks: ['coffee:dist']
      coffeeTest:
        files: ['test/**/*.coffee']
        tasks: ['coffee:test']
      compass:
        files: ['<%= yeoman.app %>/styles/{,*/}*.{scss,sass}']
        tasks: ['compass:server']
      static:
        files: [
          '<%= yeoman.cmp %>/scripts/EventEmitter.js'
          '<%= yeoman.cmp %>/scripts/bloomfilter.js'
        ]
        tasks: ['copy:dev']
      # watch end

    connect:
      options:
        port: 9000
        # change this to '0.0.0.0' to access the server from outside
        hostname: 'localhost'
      livereload:
        options:
          middleware: (connect) ->
            return [
              lrSnippet
              mountFolder connect, '.tmp'
              mountFolder connect, yeomanConfig.app
            ]
      test:
        options:
          middleware: (connect) ->
            [
              mountFolder connect, '.tmp'
              mountFolder connect, 'test'
            ]
      dist:
        options:
          middleware: (connect) ->
            return [
              mountFolder connect, yeomanConfig.dist
            ]
      # connect end
    open:
      server:
        url: 'http://localhost:<%= connect.options.port %>'

    clean:
      dist:
        files: [
          dot: true
          src: [
            '.tmp'
            '<%= yeoman.app %>/{,views/**/}*.html'
            '<%= yeoman.app %>/scripts/{,*/}*.js'
            '<%= yeoman.app %>/styles/{,*/}*.css'
            '<%= yeoman.dist %>/*'
            '!<%= yeoman.dist %>/.git*'
            'package'
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
          dest: '<%= yeoman.cmp %>'
          src: '{,views/**/}*.jade'
          ext: '.html'
        ]
      test:
        options:
          pretty: true
        files:
          '<%= yeoman.app %>/test.html': 'test/test.jade'
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
      options:
        join: true
      dist:
        files: [
            expand: true
            cwd: '<%= yeoman.app %>/scripts'
            src: '*.coffee'
            dest: '<%= yeoman.cmp %>/scripts'
            ext: '.js'
          ,
            '<%= yeoman.cmp %>/scripts/controllers.js': [
              '<%= yeoman.app %>/scripts/controllers/**/*.coffee'
            ]
          ,
            '<%= yeoman.cmp %>/scripts/services.js': [
              '<%= yeoman.app %>/scripts/services/**/*.coffee'
            ]
        ]
      test:
        files: [
            expand: true
            cwd: 'test'
            src: '*.coffee'
            dest: '<%= yeoman.cmp %>/test'
            ext: '.js'
          ,
            '<%= yeoman.cmp %>/test/mock.js': ['test/mock/**/*.coffee']
          ,
            '<%= yeoman.cmp %>/test/spec.js': ['test/spec/**/*.coffee']
        ]
      # coffee end

    compass:
      options:
        sassDir: '<%= yeoman.app %>/styles'
        cssDir: '<%= yeoman.cmp %>/styles'
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
            '<%= yeoman.cmp %>/scripts/background.js'
          ]
          '<%= yeoman.dist %>/scripts/mocha_chai_sinon.js': [
            '<%= yeoman.app %>/bower_components/mocha/mocha.js'
            '<%= yeoman.app %>/bower_components/chai/chai.js'
            '<%= yeoman.app %>/bower_components/sinon-chai/lib/sinon-chai.js'
            '<%= yeoman.app %>/bower_components/sinonjs/sinon.js'
            '<%= yeoman.app %>/test/config.js'
          ]
        ]

    # not enabled since usemin task does concat and uglify
    # check index.html to edit your build targets
    # enable this task if you prefer defining your build targets here
    uglify:
      options:
        sourceMap: (path) -> path.replace /\.js$/, '.js.map'
        sourceMappingURL: (path) ->
          path.replace(/.*\//, '').replace /\.js$/, '.js.map'
      dist:
        files: [
          '<%= yeoman.dist %>/scripts/background.js': [
            '<%= yeoman.dist %>/scripts/background.js'
          ]
          '<%= yeoman.dist %>/scripts/mocha_chai_sinon.js': [
            '<%= yeoman.dist %>/scripts/mocha_chai_sinon.js'
          ]
        ]

    useminPrepare:
      options:
        dest: '<%= yeoman.dist %>'
      html: ['<%= yeoman.cmp %>/index.html']

    usemin:
      options:
        dirs: ['<%= yeoman.dist %>']
      html: ['<%= yeoman.dist %>/*.html']
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
          '<%= yeoman.dist %>/styles/mocha.css': [
            '<%= yeoman.app %>/bower_components/mocha/mocha.css'
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
          cwd: '<%= yeoman.cmp %>'
          src: [
            '*.html'
            'views/**/*.html'
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
            'test/**/*'
          ]
        ,
          expand: true
          cwd: '.tmp/images'
          dest: '<%= yeoman.dist %>/images'
          src: [ 'generated/*' ]
        ,
          '<%= yeoman.dist %>/scripts/angular-mocks.js':
            '<%= yeoman.app %>/bower_components/angular-mocks/angular-mocks.js'
        ,
          '<%= yeoman.dist %>/scripts/EventEmitter.js':
            '<%= yeoman.app %>/bower_components/eventEmitter/EventEmitter.min.js'
        ,
          '<%= yeoman.dist %>/scripts/bloomfilter.js':
            '<%= yeoman.app %>/bower_components/bloomfilter.js/bloomfilter.js'
        ]
      dev:
        files: [
          '<%= yeoman.cmp %>/scripts/EventEmitter.js':
            '<%= yeoman.app %>/bower_components/eventEmitter/EventEmitter.js'
        ,
          '<%= yeoman.cmp %>/scripts/bloomfilter.js':
            '<%= yeoman.app %>/bower_components/bloomfilter.js/bloomfilter.js'
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
          src: [
            'app.js'
            'controllers.js'
            'services.js'
          ]
          dest: '<%= yeoman.dist %>/scripts'
        ]

    karma:
      server:
        configFile: 'karma.conf.coffee'
        background: true
        singleRun: false
        autoWatch: true
      unit:
        configFile: 'karma.conf.coffee'
        singleRun: true

  grunt.registerTask 'server', (target) ->
    if target == 'dist'
      return grunt.task.run ['build', 'open', 'connect:dist:keepalive']

    grunt.task.run [
      'clean:server'
      'concurrent:server'
      'connect:livereload'
      'open'
      'karma:server'
      'watch'
    ]

  grunt.registerTask 'test', [
    'clean:server'
    'concurrent:test'
    #'connect:test'
    'karma:unit'
  ]

  grunt.registerTask 'build', [
    'clean:dist'
    'jade'
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
