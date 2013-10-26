'use strict'

describe 'utils', () ->

  describe 'DOMParser html', ->
    describe '.world()', ->
      it 'should return document when call it', ->
        doc = utils.world '<a href="/something">test</a>', 'http://exam.p/'
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
        urls = utils.url.urls '<a href="/something">test</a>', 'http://exam.p/'
        expect(urls).to.eql ['http://exam.p/something']

  describe 'fnmatch', ->
    fnmatch = utils.fnmatch
    datas =
      'normal': [
        ['cat', 'cat', true]
        ['cat', 'category', false]
      ]
      'casefold': [
        ['cat', 'CAT', false]
      ]
      'wildcard': [
        ['c?t', 'cat', true]
        ['c??t', 'cat', false]
        ['c*', 'cats', true]
        ['c*t', 'c/a/b/t', false]
      ]
      'regexp': [
        ['ca[a-z]', 'cat', true]
        ['ca[^t]', 'cat', false]
        ['c{at,ub}s', 'cats', true]
      ]
      'escape': [
        ['\\?', '?', true]
        ['\\a', 'a', true]
        ['[\\?]', '?', true]
        ['*', '.profile', false]
        ['.*', '.profile', true]
      ]
      '**/* ** *': [
        ['**/*', 'main.rb', true]
        ['**/*', './main.rb', true]
        ['**/*', 'lib/main.rb', true]
        ['**', 'main.rb', true]
        ['**', './main.rb', true]
        ['**', 'lib/main.rb', true]
        ['*', 'dave/.profile', false]
      ]
    assert = chai.assert
    for desc, data of datas
      do (desc, data) ->
        describe desc, ->
          for cas in data
            do (cas) ->
              it cas.join(' --- '), ->
                re = fnmatch cas[0]
                fm = re.test cas[1]
                assert.strictEqual fm, cas[2], re
          return
    return
