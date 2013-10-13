'use strict'

describe 'factory: utils', () ->

  # load the service's module
  beforeEach module 'chromeRobotApp'

  # instantiate service
  utils = {}
  beforeEach inject (_utils_) ->
    utils = _utils_

  describe 'url parse', ->
    describe 'url.home()', ->
      it 'should return home uri when call it', ->
        url = utils.url.home 'http://www.google.com/url?q=x#yo'
        expect(url).to.equal 'http://www.google.com'
      it 'should support http:// https://', ->
        url = utils.url.home 'http://www.google.com/url?q=x#yo'
        expect(url).to.equal 'http://www.google.com'
        url = utils.url.home 'https://www.google.com/url?q=x#yo'
        expect(url).to.equal 'https://www.google.com'
      it 'should not support ftp://', ->
        url = utils.url.home 'ftp://www.google.com/url?q=x#yo'
        expect(url).to.be.false
