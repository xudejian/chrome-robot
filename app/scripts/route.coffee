'use strict'
angular.module('chromeRobotApp')
  .config ($stateProvider, $urlRouterProvider) ->
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
        templateUrl: 'views/site/list.html'
        controller: 'SitesCtrl'
      .state 'sites.new',
        url: '/new'
        templateUrl: 'views/site/new.html'
        controller: 'SiteNewCtrl'
