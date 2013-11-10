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

    $scope.job_class = (job) ->
      status = if angular.isNumber(job.status) then job.status else 0
      status = parseInt(status/100, 10)
      switch status
        when 1 then 'info'
        when 2 then 'success'
        when 4 then 'warning'
        when 5 then 'error'
        else ''
    message_handle = (request, sender, sendResponse) ->
      return unless request.op
      job = request.job
      $scope.$apply ->
        num = _.size($scope.jobs) - 20
        for url, p_job of $scope.jobs when num > 0 and _.isNumber job.status
          delete $scope.jobs[url]
          num -= 1
        for url, p_job of $scope.jobs when num > 0
          delete $scope.jobs[url]
          num -= 1
        $scope.jobs[job.url] = job

    chrome.runtime.onMessage.addListener message_handle
