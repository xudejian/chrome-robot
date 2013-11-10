'use strict'

sandbox_remove = (name) ->
  message =
    command: 'remove'
    name: name
  sandbox_window.postMessage message, '*'

sandbox_option = (name, option) ->
  message =
    command: 'option'
    site:
      name: name
      info_parse: option?.info_parse
  console.log 'call option event', message
  sandbox_window.postMessage message, '*'

sandbox_parse = (job) ->
  message =
    command: 'response'
    job: job
  sandbox_window.postMessage message, '*'

bind_message = (robot) ->
  robot.on 'response', (job) ->
    sandbox_parse job
    msg =
      op: 'fetched'
      job: job
    chrome.runtime.sendMessage msg
  robot.on 'option', (name, option) ->
    sandbox_option name, option
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
  sandbox_remove name

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

stop_all = ->
  for site, robot of robots
    robot.stop()
resume_all = ->
  for site, robot of robots when not site.stop
    robot.start()

restart = ->
  stop_all()
  chrome.storage.sync.get 'sites', (data) ->
    return unless data.sites
    for name, site of data.sites when not site.stop
      reload site: site

noop = ->

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

unless first_run
  first_run = true
  restart()

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

parse_response = (data) ->
  console.log data
  return unless data.success
  msg =
    op: 'parsed'
    job: data.job
  chrome.runtime.sendMessage msg

option_rv = (data) ->
  console.log data

sandbox_response_cmds =
  response: parse_response
  option: option_rv

sandbox_message_handle = (event) ->
  cmd = event.data.command || ''
  op = sandbox_response_cmds[cmd] || noop
  op event.data

window.addEventListener 'message', sandbox_message_handle
