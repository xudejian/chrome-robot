'use strict'

click_go = ->
  chrome.extension.getBackgroundPage().popupGo()
  window.close()

window.addEventListener 'load', ->
  document.getElementById('robot_go').addEventListener 'click', click_go
  chrome.tabs.getSelected null, (tab) ->
    console.log 'tab in popup', tab

  chrome.extension.getBackgroundPage().popupLoaded document
