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
      .otherwise redirectTo: '/'