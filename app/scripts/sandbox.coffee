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

option = (data, cb) ->
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
  data.parse = parsers[name].toString()
  data.parsers = parsers
  cb data

remove = (data, cb) ->
  name = data.name
  delete parsers[name]
  data.success = true
  cb data

run_parser = (data, cb) ->
  job = data.job
  name = job.name
  unless parsers[name]
    data.success = false
    data.msg = 'no parse'
    data.parsers = Object.keys parsers
    return cb data
  doc = utils.world job.content, job.url
  job.res = parsers[name] job.content, doc, {}
  cb data

cmds =
  response: run_parser
  remove: remove
  option: option
message_handle = (event) ->
  cmd = event.data.command || ''
  op = cmds[cmd] || noop
  op event.data, (result) ->
    event.source.postMessage result, event.origin

window.addEventListener 'message', message_handle
