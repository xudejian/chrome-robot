'use strict'

angular.module('chromeRobotApp')
  .factory 'Site', (Config) ->
    set: (site) ->
      Config.site_save site
    all: Config.sites

