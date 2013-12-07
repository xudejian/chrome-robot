'use strict'

angular.module('chromeRobotApp')
  .filter 'i18n', ->
    (input, substitutions) -> chrome.i18n.getMessage input, substitutions
