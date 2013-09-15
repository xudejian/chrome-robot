'use strict'

page_loaded = ->
  document.getElementById('robot_go').addEventListener 'click', click_go
  chrome.extension.getBackgroundPage().popupLoaded document

click_go = ->
  chrome.extension.getBackgroundPage().popupGo()
  window.close()

window.addEventListener 'load', page_loaded
