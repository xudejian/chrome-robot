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

    options = info_re: [ re ]
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
