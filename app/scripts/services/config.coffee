'use strict'

angular.module('chromeRobotApp')
  .factory 'config', ($q, $rootScope) ->
    noop = angular.noop
    sync_get = (key) ->
      deferred = $q.defer()
      chrome.storage.sync.get key, (data) ->
        $rootScope.$apply ->
          deferred.resolve data
      deferred.promise

    sync_set = (obj) ->
      deferred = $q.defer()
      chrome.storage.sync.set obj, ->
        $rootScope.$apply ->
          deferred.resolve obj
      deferred.promise

    sites = sync_get('sites').then (data) ->
      data = data['sites'] or {}
      _.each data, (v, k) -> delete data[k] unless v.name == k

    empty_site_config = (name) ->
      name: name
      seed: ''
      lists_regexp: []
      infos_regexp: []

    sites: (cb) ->
      sites.then cb
    site: (name, cb) ->
      sites.then (data) ->
        cb(data[name] || empty_site_config(name))
    site_destory: (name, cb) ->
      sites.then (data) ->
        delete data[name]
        sync_set(sites: data).then ->
          (cb or noop) data
    site_save: (conf, cb) ->
      name = conf.name
      sites.then (data) ->
        data[name] = conf
        sync_set(sites: data).then ->
          (cb or noop) conf
