'use strict'

describe 'Robot', ->

  robot = new window.Robot('test')

  it 'should been defined service config', () ->
    expect(!!robot).to.be.true

  describe 'maybe a bit more context here', ->
    it 'should run here few assertions', ->
