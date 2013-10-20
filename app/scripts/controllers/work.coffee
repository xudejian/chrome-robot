'use strict'

angular.module('chromeRobotApp')
  .controller 'WorkCtrl', ($scope, $window, $rootScope, Site, $http) ->
    $rootScope.title = 'Chrome Robot Work'

    $scope.jobs = []
    Site.site 'cnbeta', (site) ->
      $scope.site = site

    $scope.btn = btn =
      stop:'Stop'
      pause:'Pause'
      start: 'Start'

    $scope.start = ->
      chrome.runtime.getBackgroundPage (bg) ->
        console.log bg
      cnbeta = new Robot 'cnbeta'
      cnbeta.seed $scope.site.seed
      cnbeta.prepare_from_seed()
      cnbeta.start()

    $scope.stop = ->
      if btn.stop == "Stop"
        btn.stop = "Stopping"

    $scope.pause = ->
      if btn.pause == "Pause"
        btn.pause = "Resume"
      else
        btn.pause = "Pause"

    message_handle = (request, sender, sendResponse) ->
      $scope.$apply ->
        $scope.jobs.unshift request.job

    chrome.runtime.onMessage.addListener message_handle
