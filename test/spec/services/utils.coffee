'use strict'

describe 'factory: utils', () ->

  # load the service's module
  beforeEach module 'chromeRobotApp'

  # instantiate service
  utils = {}
  beforeEach inject (_utils_) ->
    utils = _utils_

  describe 'url parse', ->
    it 'should return home uri when call .home(uri)', ->
      url = utils.url.home 'http://www.google.com/url?q=x#yo'
      expect(url).to.equal 'http://www.google.com'
