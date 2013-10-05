'use strict'

angular.module('chromeRobotApp')
  .factory 'Site', (config) ->
    set: (site, cb) ->
      config.site_save site, cb
    all: (cb) ->
      config.sites cb
    site: (name, cb) ->
      config.site name, cb
    destory: (name, cb) ->
      config.site_destory name, cb
