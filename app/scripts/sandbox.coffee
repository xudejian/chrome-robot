'use strict'

noop = ->
parsers = {}

eval_script = (id, code, cb) ->
  script = document.createElement 'script'
  script.type = 'text/javascript'
  script.onload = ->
    document.body.removeChild script
    cb()
  script.innerHTML = code
  document.body.appendChild script

set_parse_fn = (data, cb) ->
  name = data.site.name
  info_parse = data.site.info_parse || 'return {content:content}'
  context = {}
  code = """
    exports.parse = function (content, document, window) {
      #{info_parse}
    };
  """
  (new Function 'exports', code) context
  parsers[name] = context.parse
  data.success = true
  data.name = name
  data.parse = context.parse.toString()
  cb data

remove_fn = (data, cb) ->
  name = data.name
  delete parsers[name]
  data.success = true
  cb data

parse_fn = (data, cb) ->
  job = data.job
  name = job.name
  unless parsers[name]
    data.success = false
    data.msg = 'no parse'
    data.parsers = Object.keys parsers
    return cb data
  doc = utils.world job.content, job.url
  job.res = parsers[name] job.content, doc, {}
  data.success = true
  cb data

list_fn = (data, cb) ->
  list = {}
  list[name] = fn.toString() for name, fn of parsers
  cb list

ready_fn = (data, cb) -> cb data

cmds =
  parse: parse_fn
  remove: remove_fn
  set_parse: set_parse_fn
  list: list_fn
  ready: ready_fn

message_handle = (event) ->
  cmd = event.data.command || ''
  op = cmds[cmd] || noop
  op event.data, (result) ->
    event.source.postMessage result, event.origin

window.addEventListener 'message', message_handle
