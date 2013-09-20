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
  .controller 'WorkCtrl', ($scope, $window, $rootScope) ->
    $rootScope.title = 'Chrome Robot Work'
    $scope.btn = btn =
      stop:'Stop'
      pause:'Pause'
    console.log 'work load'

    $scope.stop = ->
      if btn.stop == "Stop"
        btn.stop = "Stopping"

      chrome.runtime.sendMessage stop: btn.stop

    $scope.pause = ->
      if btn.pause == "Pause"
        btn.pause = "Resume"
      else
        btn.pause = "Pause"
      chrome.runtime.sendMessage pause: btn.pause

    $window.addEventListener "load", ->
      chrome.runtime.onMessage.addListener messageDispatch
