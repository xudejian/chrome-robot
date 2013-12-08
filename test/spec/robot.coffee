'use strict'

describe 'Robot', ->

  robot = {}

  beforeEach ->
    robot = new Robot 'test'

  it 'should been defined class Robot', () ->
    expect(robot).to.be.an.instanceof Robot

  describe 'robot seed', ->

    seed = 'http://www.robot.com/'
    options = seed: [ seed ]

    it "should contain #{seed} given #{JSON.stringify(options)}", ->
      robot.options options
      expect(robot.seeds).to.eql [ seed ]

  re = 'http://www.robot.com/test/*.htm?'
  describe 'robot info_re ' + re, ->

    options = info_regexp: [ re ]
    beforeEach ->
      robot.options options

    fn_match_re = utils.fnmatch re
    it "should contain #{fn_match_re}", ->
      expect(robot.info_re).to.eql [fn_match_re]

    match = 'http://www.robot.com/test/1.html'
    it "should match #{match}", ->
      expect(robot.is_info(match)).to.be.true

    notmatch = 'http://www.robot.com/test.html'
    it "should not match #{notmatch}", ->
      expect(robot.is_info(notmatch)).to.not.be.true

    notmatch = 'http://wwwrobot.com/test/1.html'
    it "should not match #{notmatch}", ->
      expect(robot.is_info(notmatch)).to.not.be.true

    notmatch = 'http://www1robot.com/test/1.html'
    it "should not match #{notmatch}", ->
      expect(robot.is_info(notmatch)).to.not.be.true

  re = 'http://www.robot.com/test/*.htm?'
  describe 'robot list_re ' + re, ->

    options = list_regexp: [ re ]
    beforeEach ->
      robot.options options

    fn_match_re = utils.fnmatch re
    it "should contain #{fn_match_re}", ->
      expect(robot.list_re).to.eql [fn_match_re]

    it "should be #{fn_match_re} even call options twices", ->
      robot.options options
      robot.options options
      expect(robot.list_re).to.eql [fn_match_re]

  describe 'robot param', ->
    it 'should return a=b given {"a":"b"}', ->
      expect(robot.param(a:'b')).to.eql 'a=b'
    it 'should return a=b&c=d given {"a":"b","c":"d"}', ->
      expect(robot.param(a:'b',c:'d')).to.eql 'a=b&c=d'
    it 'should return a=b%20c  given {"a":"b c"}', ->
      expect(robot.param(a:"b c")).to.eql 'a=b%20c'
    it 'should return a=%7B%7D  given {"a":{}}', ->
      expect(robot.param(a:{})).to.eql 'a=%7B%7D'
    it 'should return a=%5B%5D  given {"a":[]}', ->
      expect(robot.param(a:[])).to.eql 'a=%5B%5D'
