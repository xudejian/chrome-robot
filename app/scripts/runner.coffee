'use strict'

bind_message = (robot) ->
  robot.on 'response', (job) ->
    msg =
      op: 'fetched'
      job: job
    chrome.runtime.sendMessage msg
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

robots = {}

start = (request) ->
  site = request.site || {}
  name = site.name || ''
  return unless name and name.length
  console.log request
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
