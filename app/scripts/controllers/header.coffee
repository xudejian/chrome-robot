'use strict'

angular.module('chromeRobotApp')
  .controller 'HeaderCtrl', ($scope) ->
    $scope.show_test = (url) ->
      opt =
        id: 'mocha-robot-test'
        minWidth: 1024
      chrome.app.window.create url, opt, (win) ->
        console.log win
