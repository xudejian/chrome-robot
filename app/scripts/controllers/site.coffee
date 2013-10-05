'use strict'

update_regex = (site) ->
  unless site.seed.match /^\s*https?:\/\//i
    site.seed = 'http://www.example.com/'

  regex = site.seed
  regex = trimAfter regex, '#'
  regex = trimAfter regex, '?'
  offset = regex.lastIndexOf '/'
  if offset > 'https://'.length
    regex = regex.substring 0, offset + 1

  regex = regex.replace /([\^\$\.\*\+\?\=\!\:\|\\\(\)\[\]\{\}])/g, '\\$1'
  regex = '^' + regex
  site.regex = regex

trimAfter = (string, sep) ->
  offset = string.indexOf sep
  if offset != -1
    string.substring 0, offset
  else
    string

angular.module('chromeRobotApp')
  .controller 'SiteCtrl', ($scope, Site, $state) ->
    Site.all (sites) ->
      $scope.sites_obj = sites
      $scope.$watchCollection 'sites_obj', ->
        $scope.sites = _.map sites, (item) -> item

    $scope.detail = (site) ->
      console.log 'to detail', site
      $state.go '^.detail', site: site.name

angular.module('chromeRobotApp')
  .controller 'SiteNewCtrl', ($scope, Site, $state) ->
    $scope.site =
      name: 'cnbeta'
      seed: 'http://www.cnbeta.com/'
    $scope.update_regex = ->
      update_regex $scope.site

    $scope.add_site = (site) ->
      Site.set site, ->
        $state.go '^.list'

    $scope.cancel = ->
      $state.go '^.list'

angular.module('chromeRobotApp')
  .controller 'SiteDetailCtrl', ($scope, $state, $stateParams, Site) ->
    Site.site $stateParams.site, (site) ->
      $scope.site = site
    $scope.update_regex = ->
      update_regex $scope.site

    $scope.save_site = (site) ->
      Site.set site, ->
        $state.go '^.list'

    $scope.cancel = ->
      $state.go '^.list'

    $scope.stop = ->
      $state.go '^.list'

    $scope.destory = (site) ->
      Site.destory site.name
      $state.go '^.list'
