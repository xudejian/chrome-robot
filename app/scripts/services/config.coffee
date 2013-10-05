'use strict'

angular.module('chromeRobotApp')
  .factory 'config', ->
    sites = {}
    chrome.storage.sync.get 'sites', (data) ->
      console.log data
      sites = data.sites

    empty_site_config = (name) ->
      name: name
      seed: ''
      lists_regexp: []
      infos_regexp: []

    get_site = (name) ->
      cb(sites[name] || empty_site_config(name))

    set_site = (conf, cb) ->
      name = conf.name
      sites[name] = conf
      chrome.storage.sync.set sites: sites, ->
        console.log "save sites[#{name}] done"
        cb conf

    site: (name) ->
      get_site name
    site_save: set_site
    get: (key, cb) ->
      chrome.storage.sync.get key, cb
    sites: (cb) ->
      chrome.storage.sync.get 'sites', cb
