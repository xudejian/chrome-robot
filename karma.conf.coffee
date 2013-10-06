'use strict'
# Karma configuration
# Generated on Fri Oct 04 2013 16:54:29 GMT+0800 (CST)

module.exports = (config) ->
  config.set

    # base path, that will be used to resolve all patterns, eg. files, exclude
    basePath: ''

    # frameworks to use
    frameworks: ['jasmine']

    # list of files / patterns to load in the browser
    files: [
      'app/bower_components/angular/angular.js'
      'app/bower_components/angular-ui-router/release/angular-ui-router.js'
      'app/bower_components/angular-resource/angular-resource.js'
      'app/bower_components/angular-sanitize/angular-sanitize.js'
      'app/bower_components/angular-bootstrap/ui-bootstrap-tpls.js'
      'app/bower_components/angular-mocks/angular-mocks.js'
      'app/scripts/app.coffee'
      'app/scripts/route.coffee'
      'app/scripts/services/**/*.coffee'
      'app/scripts/controllers/**/*.coffee'
      'app/scripts/**/*.coffee'
      'test/mock/**/*.coffee'
      'test/spec/**/*.coffee'
    ]

    # list of files to exclude
    exclude: [
      'app/scripts/background.coffee'
      'app/scripts/robot.coffee'
    ]

    # test results reporter to use
    # possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ['progress']

    # web server port
    port: 9876

    # enable / disable colors in the output (reporters and logs)
    colors: true

    # level of logging
    # possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO

    # enable / disable watching file and executing tests whenever any file changes
    autoWatch: true

    # Start these browsers, currently available:
    # - Chrome
    # - ChromeCanary
    # - Firefox
    # - Opera
    # - Safari (only Mac)
    # - PhantomJS
    # - IE (only Windows)
    browsers: ['Chrome']

    # If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000

    # Continuous Integration mode
    # if true, it capture browsers, run tests and exit
    singleRun: false
