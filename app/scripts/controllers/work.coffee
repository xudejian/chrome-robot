'use strict'

angular.module('chromeRobotApp')
  .controller 'WorkCtrl', ($scope, $rootScope, Site) ->
    $rootScope.title = 'Chrome Robot Work'

    $scope.jobs = {}
    Site.site 'cnbeta', (site) ->
      $scope.site = site

    $scope.btn = btn =
      stop:'Stop'
      pause:'Pause'
      start: 'Start'

    $scope.start = ->
      msg =
        cmd: 'start'
        site: $scope.site
      chrome.runtime.sendMessage msg

    $scope.stop = ->
      if btn.stop == "Stop"
        btn.stop = "Stopping"
      msg =
        cmd: 'stop'
        site: $scope.site
      chrome.runtime.sendMessage msg

    $scope.pause = ->
      if btn.pause == "Pause"
        btn.pause = "Resume"
      else
        btn.pause = "Pause"

    message_handle = (request, sender, sendResponse) ->
      return unless request.op
      console.log request
      job = request.job
      $scope.$apply ->
        if 20 < _.size $scope.jobs
          p_job = _.find $scope.jobs, (job) -> _.isNumber job.status
          delete $scope.jobs[p_job.url] if p_job
        $scope.jobs[job.url] = job

    chrome.runtime.onMessage.addListener message_handle
