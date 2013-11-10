'use strict'

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

    $scope.stop = (site) ->
      Site.stop site

angular.module('chromeRobotApp')
  .controller 'SiteFormCtrl', ($scope, Site, $state) ->

    to_regex = (str) ->
      re = str || ''
      re = re.replace /([\^\$\.\*\+\?\=\!\:\|\\\(\)\[\]\{\}])/g, '\\$1'
      "^#{re}"
    append_star = (str) ->
      if '*' is str.substr -1
        str
      else
        "#{str}*"

    concat_and_uniq = (site, name, value) ->
      site[name] ?= []
      site[name] = _.compact _.uniq site[name].concat value
    without = (site, name, value) ->
      site[name] ?= []
      site[name] = _.without site[name], value

    $scope.suggest = (re) ->
      return [] if '^' is re.substr 0, 1
      [append_star(re), to_regex(re)]

    $scope.add_seed = (site) ->
      concat_and_uniq site, 'seed', $scope.new_seed
      $scope.new_seed = ''

    $scope.add_list_regex = (site) ->
      concat_and_uniq site, 'list_regexp', $scope.list_re
      $scope.list_re = ''

    $scope.add_info_regex = (site) ->
      concat_and_uniq site, 'info_regexp', $scope.info_re
      $scope.info_re = ''

    $scope.rm_seed = (site, seed) ->
      without site, 'seed', seed
      $scope.new_seed = seed

    $scope.rm_list_re = (site, regex) ->
      without site, 'list_regexp', regex
      $scope.list_re = regex

    $scope.rm_info_re = (site, regex) ->
      without site, 'info_regexp', regex
      $scope.info_re = regex

    $scope.save = (site) ->
      Site.set site, ->
        $state.go '^.list'

    $scope.cancel = ->
      $state.go '^.list'

    $scope.editorOptions =
      lineWrapping: true
      lineNumbers: true
      theme: 'solarized'
      mode: 'javascript'

angular.module('chromeRobotApp')
  .controller 'SiteNewCtrl', ($scope) ->

    $scope.site =
      name: 'cnbeta'
      stop: true
      seed: ['http://www.cnbeta.com/']
      list_regexp: []
      info_regexp: []
      info_parse: '''
        ;(function(export){
          export.parse = function (content, document, window) {
          };
        })(this);
        '''

angular.module('chromeRobotApp')
  .controller 'SiteDetailCtrl', ($scope, $state, $stateParams, Site) ->

    Site.site $stateParams.site, (site) ->
      $scope.site = angular.copy site

    $scope.stop = (site) ->
      Site.stop site
      $state.go '^.list'

    $scope.clean = (site) ->
      Site.clean site

    $scope.destory = (site) ->
      Site.destory site.name
      $state.go '^.list'
