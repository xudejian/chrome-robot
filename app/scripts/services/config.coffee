'use strict'

angular.module('chromeRobotApp')
  .provider 'Config', ->
    empty_site_config = (name) ->
      name: name
      seed: ''
      lists_regexp: []
      infos_regexp: []

    get_site = (name, cb) ->
      chrome.storage.sync.get 'sites', (data) ->
        console.log data
        cb(data.sites[name] || empty_site_config(name))

    set_site = (conf) ->
      name = conf.name
      chrome.storage.sync.get 'sites', (data) ->
        sites = data.sites || {}
        sites[name] = conf
        chrome.storage.sync.set sites: sites, ->
          console.log "save sites[#{name}] done"

    @$get = ->
      site: (name, cb) ->
        get_site name, cb
      site_save: set_site
      get: (key, cb) ->
        chrome.storage.sync.get key, cb
      sites: (cb) ->
        chrome.storage.sync.get 'sites', (data) ->
          cb data
