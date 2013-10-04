'use strict'

xdescribe 'Service: config', () ->

  # load the service's module
  beforeEach module 'chromeRobotApp'

  # instantiate service
  config = {}
  chrome = {}
  beforeEach inject (_Config_) ->
    config = _Config_
    chrome =
      storage:
        sync:
          get: ->
    spyOn chrome.storage.sync, 'get'

  it 'should been defined service config', () ->
    expect(!!config).toBe true

  describe 'api: config.site', () ->
    it 'should have a function site to load/set robot site config', () ->
      expect(config.site).toBeDefined()

    describe 'config storage data with chrome.storage', () ->
      it 'should be read config with chrome.storage.sync.get', () ->
        config.site 'site'
        expect(chrome.storage.sync.get)
          .toHaveBeenCalledWith 'site', jasmine.any(Function)

    describe 'response of config.site', () ->
      it 'should be a object when call config.site("site_name")', () ->
        expect(config.site('site')).toEqual jasmine.any Object

      it 'should contain name', () ->
        expect(config.site('site').name).toBeDefined()

      it 'should contain seed', () ->
        expect(config.site('site').seed).toBeDefined()

      it 'should contain lists regexp', () ->
        expect(config.site('site').lists_regexp).toBeDefined()

      it 'should contain infos regexp', () ->
        expect(config.site('site').infos_regexp).toBeDefined()

      it 'should be different from two different param', () ->
        expect(config.site('site')).not.toBe config.site 'site_2'
