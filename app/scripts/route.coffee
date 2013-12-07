'use strict'
angular.module('chromeRobotApp')
  .config ($stateProvider, $urlRouterProvider, $compileProvider) ->
    $urlRouterProvider.otherwise '/'
    $stateProvider
      .state 'main',
        url: '/'
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .state 'options',
        url: '/options'
        templateUrl: 'views/options.html'
        controller: 'OptionsCtrl'
      .state 'works',
        url: '/works'
        templateUrl: 'views/work.html'
        controller: 'WorkCtrl'

      .state 'sites',
        url: '/sites'
        abstract: true
        templateUrl: 'views/site.html'
      .state 'sites.list',
        url: ''
        templateUrl: 'views/site/list.html'
        controller: 'SiteCtrl'
      .state 'sites.detail',
        url: '/detail/:site'
        templateUrl: 'views/site/detail.html'
        controller: 'SiteDetailCtrl'
      .state 'sites.new',
        url: '/new'
        templateUrl: 'views/site/new.html'
        controller: 'SiteNewCtrl'


    cur_wl = $compileProvider.imgSrcSanitizationWhitelist().toString()
    add_wl = '|filesystem:chrome-extension:|blob:chrome-extension%3A'
    new_wl = cur_wl.slice(0, -1) + add_wl + cur_wl.slice(-1)
    $compileProvider.imgSrcSanitizationWhitelist new_wl
