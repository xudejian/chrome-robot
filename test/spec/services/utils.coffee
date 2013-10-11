'use strict'

describe 'factory: utils', () ->

  # load the service's module
  beforeEach module 'chromeRobotApp'

  # instantiate service
  utils = {}
  beforeEach inject (_utils_) ->
    utils = _utils_

  it 'should been defined service utils', () ->
    expect(!!utils).toBe true
