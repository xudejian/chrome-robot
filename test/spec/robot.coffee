'use strict'

describe 'Robot', ->

  robot = {}
  beforeEach inject ($http) ->
    robot = new Robot('test', $http)

  it 'should been defined service config', () ->
    expect(!!robot).to.be.true

  describe 'maybe a bit more context here', ->
    it 'should run here few assertions', ->
