'use strict'

noop = ->

parse_rv = (data) ->
  return unless data.success
  job = data.job
  msg =
    op: 'parsed'
    job: job
  chrome.runtime.sendMessage msg
  name = job.name || ''
  return unless robots[name]
  json =
    site: name
    info: job.res
    url: job.url
  robots[name].submit_data json

console_rv = (data) ->
  console.log data

sandbox_response_cmds =
  parse: parse_rv
  set_parse: console_rv
  list: console_rv
  ready: console_rv

sandbox_message_handle = (event) ->
  cmd = event.data.command || ''
  (sandbox_response_cmds[cmd] || noop) event.data

window.addEventListener 'message', sandbox_message_handle

class Sandbox extends EventEmitter
  constructor: ->
    @_ready = false
    sandbox = document.createElement 'iframe'
    sandbox.src = 'sandbox.html'
    sandbox.id = 'sandbox'
    document.body.appendChild sandbox
    @window = sandbox.contentWindow
    @window.addEventListener 'load', ( =>
      @_ready = true
      @emit 'ready'
    ), false

  ready: (cb) ->
    return cb() if @_ready
    @once 'ready', cb

  check_ready: ->
    message =
      command: 'ready'
    @send message

  send: (msg) ->
    @window.postMessage msg, '*'

  command: (cmd, msg={}) ->
    msg.command = cmd
    @send msg

  remove: (name) ->
    @command 'remove', name: name

  set_parse: (name, option) ->
    @command 'set_parse', site:
      name: name
      info_parse: option?.info_parse

  parse: (job) ->
    @command 'parse', job: job

  list: ->
    @command 'list'

sandbox = new Sandbox()

bind_message = (robot) ->
  robot.on 'response', (job) ->
    sandbox.parse job if job.info
    msg =
      op: 'fetched'
      job: job
    chrome.runtime.sendMessage msg
  robot.on 'option', (name, option) ->
    sandbox.set_parse name, option
  robot.on 'todo.list', (job) ->
    msg =
      op: 'todo'
      job: job
      type: 'list'
    chrome.runtime.sendMessage msg
  robot.on 'todo.info', (job) ->
    msg =
      op: 'todo'
      job: job
      type: 'info'
    chrome.runtime.sendMessage msg
  robot.on 'request', (job) ->
    msg =
      op: 'request'
      job: job
    chrome.runtime.sendMessage msg
  robot.on 'timeout', (job) ->
    msg =
      op: 'timeout'
      job: job
    chrome.runtime.sendMessage msg

robots = {}

start = (request) ->
  site = request.site || {}
  name = site.name || ''
  return unless name and name.length
  unless robots[name]
    robots[name] = robot = new Robot name
    bind_message robot

  robot = robots[name]
  robot.stop()
  robot.options site
  robot.start()

stop = (request) ->
  site = request.site || {}
  name = site.name || ''
  return unless robots[name]
  robots[name].stop()

remove = (request) ->
  site = request.site || {}
  name = site.name || ''
  return unless robots[name]
  robots[name].stop()
  delete robots[name]
  sandbox.remove name

clean = (request) ->
  site = request.site || {}
  name = site.name || ''
  return unless robots[name]
  robots[name].clean()

reload = (request) ->
  site = request.site || {}
  name = site.name || ''
  return unless name and name.length
  unless robots[name]
    robots[name] = robot = new Robot name
    bind_message robot

  robot = robots[name]
  robot.options site
  robot.start() unless site.stop

stop_all = (request, sender, sendResponse, done=noop) ->
  for site, robot of robots
    robot.stop()
  done()
resume_all = (request, sender, sendResponse, done=noop) ->
  for site, robot of robots when not site.stop
    robot.start()
  done()

restart = (request, sender, sendResponse, done=noop) ->
  stop_all()
  chrome.storage.sync.get 'sites', (data) ->
    for name, site of data.sites when not site.stop
      reload site: site
    done()

robot_cmds =
  start: start
  stop: stop
  clean: clean
  remove: remove
  reload: reload
  restart: restart
  stop_all: stop_all
  resume_all: resume_all

message_handle = (request, sender, sendResponse) ->
  cmd = request.cmd || ''
  op = robot_cmds[cmd] || noop
  op request, sender, sendResponse
chrome.runtime.onMessage.addListener message_handle

on_idle = ->
  for site, robot of robots
    robot.system_busy false

on_system_busy = ->
  for site, robot of robots
    robot.system_busy true

idle_event =
  idle: on_idle
  locked: on_idle
  active: on_system_busy

idle_bind = (state) ->
  (idle_event[state] || noop)()

chrome.idle.onStateChanged.addListener idle_bind
chrome.runtime.onSuspend.addListener ->

sandbox.ready ->
  restart ->
    sandbox.list()
