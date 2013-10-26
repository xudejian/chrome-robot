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
