'use strict'

describe 'Service: config', () ->

  # load the service's module
  beforeEach module 'chromeRobotApp'

  # instantiate service
  config = {}
  beforeEach inject (_config_) ->
    config = _config_

  it 'should been defined service config', () ->
    expect(!!config).to.be.true

  describe 'api: config.site', () ->
    it 'should have a function site to load/set robot site config', () ->
      expect(config.sites).to.be.a 'function'
