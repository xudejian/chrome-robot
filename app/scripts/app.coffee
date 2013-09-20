'use strict'

angular.module('chromeRobotApp', [
  'ngRoute'
  'ui.bootstrap'
])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/work',
        templateUrl: 'views/work.html'
        controller: 'WorkCtrl'
      .otherwise redirectTo: '/'
