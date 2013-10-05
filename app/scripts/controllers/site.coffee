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
  .controller 'SiteCtrl', ($scope, Site) ->
    Site.all (sites) ->
      console.log 'load site once'
      $scope.$apply ->
        $scope.sites = sites

angular.module('chromeRobotApp')
  .controller 'SiteNewCtrl', ($scope, Site, $state) ->
    $scope.site =
      name: 'cnbeta'
      seed: 'http://www.cnbeta.com/'
    $scope.update_regex = ->
      update_regex $scope.site

    $scope.add_site = (site) ->
      Site.set site, ->
        $state.go '^'

    $scope.cancel = ->
      $state.go '^'
