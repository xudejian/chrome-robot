'use strict'

angular.module('chromeRobotApp')
  .factory 'Site', (config, $http, utils) ->
    set: (site, cb) ->
      config.site_save site, cb
    all: (cb) ->
      config.sites cb
    site: (name, cb) ->
      config.site name, cb
    stop: (site) ->
      site.stop = not site.stop
      config.site_save site
    destory: (name, cb) ->
      config.site_destory name, cb
    get_logo: (site, cb) ->
      favicon = utils.url.home(site.seed) + '/favicon.ico'
      console.log favicon
      $http.get(favicon, responseType: 'blob')
        .success (data) ->
          cb site, data
