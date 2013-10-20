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

url =
  home: (url) ->
    url = url.toLowerCase()
    unless _.str.startsWith(url, 'http://') or
        _.str.startsWith(url, 'https://')
      return off
    idx = url.indexOf '/', 8
    return url if idx == -1
    url.substr 0, idx
  urls: (doc, base_url) ->
    if base_url
      doc = world doc, base_url
    (link.href for link in doc.links)

@utils =
  world: world
  url: url
