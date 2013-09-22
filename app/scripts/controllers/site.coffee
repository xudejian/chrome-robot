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
  .controller 'SitesCtrl', ($scope) ->

angular.module('chromeRobotApp')
  .controller 'SiteNewCtrl', ($scope) ->
    $scope.update_regex = ->
      update_regex $scope.site

    $scope.add_site = (site) ->
      console.log site
