'use strict'

world = (html, base_url) ->
  # https://gist.github.com/eligrey/1129031
  # http://jsperf.com/html-parsing-performance/4
  doc = (new DOMParser).parseFromString html, "text/html"
  if base_url and not doc.baseURI
    base = doc.createElement 'base'
    base.href = base_url
    doc.head.appendChild base
  doc

FNM_CASEFOLD = 1
FNM_PATHNAME = 2
FNM_NOESCAPE = 4

fnmatch = (pattern, flags) ->
  parsedPattern = pattern
    .replace(/\*\*\/\*/g, '**')
    .replace(/\//g, 'FNMATCH_SEP')
    .replace(/\*\*/g, 'FNMATCH_ALL')
    .replace(/\*/g, 'FNMATCH_FOLDER')
    .replace(/\\\?/g, 'FNMATCH_MATCH_ONE')
    .replace(/((?!\\))\?/g, '$1.')
    .replace(/FNMATCH_SEP/g, '\\/')
    .replace(/FNMATCH_MATCH_ONE/g, '\\\?')
    .replace(/FNMATCH_ALL/g, '.*')
    .replace(/FNMATCH_FOLDER/g, '[^\\/]+')
  parsedPattern = '^' + parsedPattern + '$'
  new RegExp parsedPattern, flags

smart_regexp = (pattern, flags) ->
  if '^' is pattern.substr 0, 1
    return new RegExp pattern, flags
  return fnmatch pattern, flags

url =
  is_http: (url) ->
    url = url.toLowerCase()
    url.substr(0, 7) == 'http://' or url.substr(0, 8) == 'https://'
  home: (uri) ->
    return off unless url.is_http uri
    idx = uri.indexOf '/', 8
    return uri if idx == -1
    uri.substr 0, idx
  urls: (doc, base_url) ->
    if base_url
      doc = world doc, base_url
    (link.href for link in doc.links)

@utils =
  world: world
  url: url
  fnmatch: fnmatch
  smart_regexp: smart_regexp
