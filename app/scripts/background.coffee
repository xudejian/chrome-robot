'use strict'

chrome.runtime.onInstalled.addListener (details) ->

# Listens for the app launching then creates the window
# @see http://developer.chrome.com/trunk/apps/app.window.html
chrome.app.runtime.onLaunched.addListener ->
  opt =
    bounds:
      width: 1024
      height: 768
      left: 10
      top: 10
    minWidth: 1024
    minHeight: 768
  chrome.app.window.create 'index.html#/works', opt, (created_window) ->
    chrome.notifications.create 'chrome-robot',
        type: 'basic'
        iconUrl:'images/icon-38.png'
        title: 'Hello!'
        message: 'Lorem ipsum ...'
      , (notification_id) ->


chrome.runtime.onSuspend.addListener ->
  # Do some simple clean-up tasks.
