'use strict'

describe 'Service: site', () ->

  # load the service's module
  beforeEach module 'chromeRobotApp'

  # instantiate service
  site = {}
  beforeEach inject (_Site_) ->
    site = _Site_

  it 'should do something', () ->
    expect(!!site).to.be.true
