'use strict'

angular.module('chromeRobotApp')
  .factory 'Site', (config, $http) ->
    set: (site, cb) ->
      config.site_save site, cb
    all: (cb) ->
      config.sites cb
    site: (name, cb) ->
      config.site name, cb
    stop: (site) ->
      site.stop = not site.stop
      config.site_save site

      msg =
        cmd: if site.stop then 'stop' else 'start'
        site: site
      chrome.runtime.sendMessage msg

    destory: (name, cb) ->
      config.site_destory name, cb
    get_logo: (site, cb) ->
      return unless Array.isArray site.seed
      return unless utils.url.is_http site.seed[0]
      favicon = utils.url.home(site.seed[0]) + '/favicon.ico'
      $http.get(favicon, responseType: 'blob')
        .success (data) ->
          cb site, data
