'use strict'

chrome.runtime.onInstalled.addListener (details) ->
  chrome.notifications.create 'chrome-robot',
      type: 'basic'
      iconUrl:'images/icon-38.png'
      title: 'Hello!'
      message: 'Welcome to Chrome Robot'
    , (notification_id) ->

show_app_window = ->
  opt =
    id: 'chrome-robot'
    bounds:
      width: 1024
      height: 768
      left: 10
      top: 10
    minWidth: 1024
    minHeight: 768
  chrome.app.window.create 'index.html#/works', opt, (app_window) ->
    app_window.contentWindow.onload = ->
    chrome.storage.local.set windowVisible: true
    app_window.onClosed.addListener ->
      chrome.storage.local.set windowVisible: false

chrome.app.runtime.onLaunched.addListener show_app_window
chrome.app.runtime.onRestarted.addListener ->
  chrome.storage.local.get 'windowVisible', (data) ->
    if data.windowVisible
      show_app_window()

chrome.runtime.onSuspend.addListener ->
  # Do some simple clean-up tasks.
