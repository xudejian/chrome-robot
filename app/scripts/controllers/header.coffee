'use strict'

angular.module('chromeRobotApp')
  .controller 'HeaderCtrl', ($scope) ->
    $scope.test = ->
      chrome.app.window.create 'test.html', id: 'mocha-robot-test'
