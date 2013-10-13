'use strict'

angular.module('chromeRobotApp')
  .factory 'utils', () ->

    url =
      home: (url) ->
        url = url.toLowerCase()
        unless _.str.startsWith(url, 'http://') or _.str.startsWith(url, 'https://')
          return off
        idx = url.indexOf '/', 8
        return url if idx == -1
        url.substr 0, idx

    utils =
      url: url
