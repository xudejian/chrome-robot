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

angular.module('mockedChrome', [])
  .value 'chrome', chrome
