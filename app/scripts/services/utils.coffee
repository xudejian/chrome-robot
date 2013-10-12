'use strict'

angular.module('chromeRobotApp')
  .factory 'utils', () ->

    url =
      home: (url) ->
        infos = url.split ':', 2

    utils =
      url: url
