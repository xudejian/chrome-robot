'use strict'
angular.module('chromeRobotApp')
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/options',
        templateUrl: 'views/options.html'
        controller: 'OptionsCtrl'
      .when '/works',
        templateUrl: 'views/work.html'
        controller: 'WorkCtrl'
      .when '/sites/new',
        templateUrl: 'views/site/new.html'
        controller: 'SiteNewCtrl'
      .otherwise redirectTo: '/'
