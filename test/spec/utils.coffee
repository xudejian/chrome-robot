'use strict'

describe 'utils', () ->

  utils = window.utils

  describe 'DOMParser html', ->
    describe '.world()', ->
      it 'should return document when call it', ->
        doc = utils.world '<a href="/something">test</a>', 'http://www.example.com/'
        expect(doc).to.be.an 'object'
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
    describe 'url.urls()', ->
      it 'should return home url when call it with <a href="/something">', ->
        urls = utils.url.urls '<a href="/something">test</a>', 'http://www.example.com/'
        expect(urls).to.eql ['http://www.example.com/something']
