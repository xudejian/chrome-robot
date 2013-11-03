'use strict'

angular.module('chromeRobotApp')
  .controller 'WorkCtrl', ($scope) ->

    $scope.jobs = {}

    $scope.status = 'running'

    $scope.restart = ->
      msg =
        cmd: 'restart'
      chrome.runtime.sendMessage msg
      $scope.status = 'running'

    $scope.pause = ->
      msg =
        cmd: 'stop_all'
      chrome.runtime.sendMessage msg
    $scope.resume = ->
      msg =
        cmd: 'resume_all'
      chrome.runtime.sendMessage msg

    message_handle = (request, sender, sendResponse) ->
      return unless request.op
      job = request.job
      $scope.$apply ->
        if 20 < _.size $scope.jobs
          p_job = _.find $scope.jobs, (job) -> _.isNumber job.status
          delete $scope.jobs[p_job.url] if p_job
        $scope.jobs[job.url] = job

    chrome.runtime.onMessage.addListener message_handle
