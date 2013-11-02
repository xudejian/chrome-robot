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

chrome.idle.onStateChanged.addListener (state) ->
  console.log state

robots = {}

robot_cmds =
  start: (request, sender, sendResponse) ->
    site = request.site || {}
    name = site.name || ''
    return unless name and name.length
    console.log request
    unless robots[name]
      robots[name] = robot = new Robot name, site
      bind_message robot

    robot = robots[name]
    robot.stop()
    robot.options site
    robot.start()

  stop: (request, sender, sendResponse) ->
    site = request.site || {}
    name = site.name || ''
    return unless robots[name]
    robots[name].stop()

message_handle = (request, sender, sendResponse) ->
  cmd = request.cmd || ''
  op = robot_cmds[cmd] || ->
  op request, sender, sendResponse
chrome.runtime.onMessage.addListener message_handle
