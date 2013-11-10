'use strict'

chrome =
  storage:
    local:
      get: ->
      set: ->
    sync:
      get: ->
      set: ->

window.chrome = window.chrome || chrome
window.chrome.storage = window.chrome.storage || chrome.storage

angular.module('mockedChrome', [])
  .value 'chrome', chrome
