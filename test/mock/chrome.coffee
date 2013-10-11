'use strict'

window.chrome = chrome =
  storage:
    local:
      get: ->
      set: ->
    sync:
      get: ->
      set: ->

angular.module('mockedChrome', [])
  .value 'chrome', chrome
