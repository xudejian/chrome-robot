'use strict'

angular.module('chromeRobotApp')
  .controller 'WorkCtrl', ($scope, $window, $rootScope, Site, $http) ->
    $rootScope.title = 'Chrome Robot Work'

    $scope.jobs = {}
    Site.site 'cnbeta', (site) ->
      $scope.site = site

    $scope.btn = btn =
      stop:'Stop'
      pause:'Pause'
      start: 'Start'

    $scope.start = ->
      cnbeta = new Robot 'cnbeta'
      cnbeta.seed $scope.site.seed
      cnbeta.add_info_re 'http://www.cnbeta.com/articles/\\d+.htm'
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
      job = request.job
      console.log request.op, request.job.url
      $scope.$apply ->
        if 20 < _.size $scope.jobs
          p_job = _.find $scope.jobs, (job) -> _.isNumber job.status
          delete $scope.jobs[p_job.url] if p_job
        $scope.jobs[job.url] = job

    chrome.runtime.onMessage.addListener message_handle
