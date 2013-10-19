'use strict'

messageDispatch = (request, sender, sendResponse) ->
  # what are we using
  element = switch request.method
    when "getElementById"
      document.getElementById request.id
    when "getElementsByTag"
      document.getElementById request.id

  # what are we doing
  switch request.action
    when "getInnerHTML" then sendResponse element.innerHTML
    when "getValue" then sendResponse element.value
    when "setInnerHTML" then element.innerHTML = request.value
    when "setValue" then element.value = request.value
    when "insertResultBodyTR" then insertResultBodyTR request.value

insertResultBodyTR = (innerHTML) ->
  tbody = document.getElementById 'resultbody'
  tr = document.createElement 'tr'
  tr.innerHTML += innerHTML
  tbody.appendChild tr


angular.module('chromeRobotApp')
  .controller 'WorkCtrl', ($scope, $window, $rootScope, Site, $http, utils) ->
    $rootScope.title = 'Chrome Robot Work'

    $scope.jobs = []
    Site.site 'cnbeta', (site) ->
      $scope.site = site

    $scope.btn = btn =
      stop:'Stop'
      pause:'Pause'
      start: 'Start'

    $scope.start = ->
      site =
        url: $scope.site.seed
        get_url_count: 0
        referrer: $scope.site.seed
        status: 'pending'
      add_job = (site) -> $scope.jobs.push site
      add_job site

      do_jobs = (jobs) ->
        site = jobs.shift()
        do (site) ->
          site.status = 'fetching'
          $http.get(site.url)
            .success (data, status) ->
              site.status = status
              site.document = utils.world data, site.url
              site.links = utils.url.urls site.document
              site.get_url_count = site.links.length
            .success ->
              for link in site.links
                n =
                  url: link
                  get_url_count: 0
                  referrer: site.url
                  status: 'pending'
                add_job n
      do_jobs $scope.jobs

    $scope.stop = ->
      if btn.stop == "Stop"
        btn.stop = "Stopping"

      chrome.runtime.sendMessage stop: true

    $scope.pause = ->
      if btn.pause == "Pause"
        btn.pause = "Resume"
      else
        btn.pause = "Pause"
      chrome.runtime.sendMessage pause: true

    $window.addEventListener "load", ->
      chrome.runtime.onMessage.addListener messageDispatch
