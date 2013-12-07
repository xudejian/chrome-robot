#
# DOMParser HTML extension
# 2012-09-04
#
# By Eli Grey, http://eligrey.com
# Public domain.
# NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.
#

#! @source https://gist.github.com/1129031
#global document, DOMParser
"use strict"

DOMParser_proto = DOMParser.prototype
real_parseFromString = DOMParser_proto.parseFromString

# Firefox/Opera/IE throw errors on unsupported types
try
  # WebKit returns null on unsupported types
  return if (new DOMParser).parseFromString "", "text/html"
  # text/html parsing is natively supported
catch ex
  console.log ex

DOMParser_proto.parseFromString = (markup, type) ->
  if /^\s*text\/html\s*(?:;|$)/i.test type
    doc = document.implementation.createHTMLDocument ""
    doc_elt = doc.documentElement
    doc_elt.innerHTML = markup
    first_elt = doc_elt.firstElementChild
    if doc_elt.childElementCount == 1 and
        first_elt.localName.toLowerCase() == "html"
      doc.replaceChild first_elt, doc_elt
    doc
  else
    real_parseFromString.apply @, arguments
