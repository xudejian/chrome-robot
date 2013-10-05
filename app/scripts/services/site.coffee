'use strict'

angular.module('chromeRobotApp')
  .factory 'Site', (config) ->
    set: (site, cb) ->
      config.site_save site, cb
    all: (cb) ->
      config.sites (data) ->
        cb _.map data.sites, (item) -> item
