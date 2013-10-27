'use strict'

site_helper = ($state, Site) ->
  to_regex = (str) ->
    re = str || ''
    re = re.replace /([\^\$\.\*\+\?\=\!\:\|\\\(\)\[\]\{\}])/g, '\\$1'
    "^#{re}"

  concat_and_uniq = (site, name, value) ->
    site[name] ?= []
    site[name] = _.uniq site[name].concat value

  helper =
    suggest: (re) -> [ to_regex(re) ]

    add_seed: (site, seed) ->
      concat_and_uniq site, 'seed', seed

    add_list_regex: (site, regex) ->
      concat_and_uniq site, 'list_regexp', regex

    add_info_regex: (site, regex) ->
      concat_and_uniq site, 'info_regexp', regex

    save: (site) ->
      Site.set site, ->
        $state.go '^.list'

    cancel: ->
      $state.go '^.list'

    bind_action: ($scope, actions) ->
      $scope[action] = helper[action] for action in actions when helper[action]


angular.module('chromeRobotApp')
  .controller 'SiteCtrl', ($scope, Site, $state) ->
    Site.all (sites) ->
      $scope.sites_obj = sites
      for key, site of sites
        delete site.ico if site.ico
        Site.get_logo site, (site, data) ->
          site.ico = window.webkitURL.createObjectURL data
      $scope.$watchCollection 'sites_obj', ->
        $scope.sites = _.map sites, (item) -> item

    $scope.detail = (site) ->
      $state.go '^.detail', site: site.name

    $scope.stop = (site, $event) ->
      $event.stopPropagation()
      Site.stop site

angular.module('chromeRobotApp')
  .controller 'SiteNewCtrl', ($scope, Site, $state) ->

    helper = site_helper $state, Site
    helper.bind_action $scope, [
      'suggest'
      'add_seed'
      'add_list_regex'
      'add_info_regex'
      'save'
      'cancel'
    ]

    $scope.site =
      name: 'cnbeta'
      seed: ['http://www.cnbeta.com/']
      list_regexp: []
      info_regexp: []

angular.module('chromeRobotApp')
  .controller 'SiteDetailCtrl', ($scope, $state, $stateParams, Site) ->

    helper = site_helper $state, Site
    helper.bind_action $scope, [
      'suggest'
      'add_seed'
      'add_list_regex'
      'add_info_regex'
      'save'
      'cancel'
    ]

    Site.site $stateParams.site, (site) ->
      $scope.site = site

    $scope.stop = (site) ->
      Site.stop site
      $state.go '^.list'

    $scope.destory = (site) ->
      Site.destory site.name
      $state.go '^.list'
