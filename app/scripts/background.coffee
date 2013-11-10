'use strict'

chrome.runtime.onInstalled.addListener (details) ->
  return
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
      left: 10
      top: 10
    minWidth: 1024
    minHeight: 768
  chrome.app.window.create 'index.html#/works', opt, (app_window) ->
    chrome.storage.local.set windowVisible: true
    app_window.onClosed.addListener ->
      chrome.storage.local.set windowVisible: false

chrome.app.runtime.onLaunched.addListener show_app_window
chrome.app.runtime.onRestarted.addListener ->
  check_sandbox()
  chrome.storage.local.get 'windowVisible', (data) ->
    if data.windowVisible
      show_app_window()

chrome.runtime.onSuspend.addListener ->
  # Do some simple clean-up tasks.

check_sandbox = ->
  iframe = document.getElementsByTagName 'iframe'
  return if iframe.length
  iframe = document.createElement 'iframe'
  iframe.style.display = 'none'
  iframe.src = 'sandbox.html'
  document.body.appendChild iframe

check_sandbox()
