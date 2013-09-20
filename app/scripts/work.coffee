'use strict'
console.log 'work load'

messageDispatch = (request, sender, sendResponse) ->
  # what are we using
  element = switch request.method
    when "getElementById"
      document.getElementById request.id
    when "getElementsByTag"
      document.getElementById request.id

  # what are we doing
  switch request.action
    when "getInnerHTML" then sendResponse element.innerHTML
    when "getValue" then sendResponse element.value
    when "setInnerHTML" then element.innerHTML = request.value
    when "setValue" then element.value = request.value
    when "insertResultBodyTR" then insertResultBodyTR request.value

clickStop = ->
  elem = document.getElementById("stopSpider")
  if elem.value == "Stop"
    elem.value = "Stopping"

  chrome.runtime.sendMessage stop: elem.value

clickPause = ->
  elem = document.getElementById "pauseSpider"
  if elem.value == "Pause"
    elem.value = "Resume"
  else
    elem.value = "Pause"
  chrome.runtime.sendMessage pause: elem.value

pageLoaded = ->
  document.getElementById("stopSpider").addEventListener "click", clickStop
  document.getElementById("pauseSpider").addEventListener "click", clickPause
  chrome.runtime.onMessage.addListener messageDispatch

insertResultBodyTR = (innerHTML) ->
  tbody = document.getElementById 'resultbody'
  tr = document.createElement 'tr'
  tr.innerHTML += innerHTML
  tbody.appendChild tr

window.addEventListener "load", pageLoaded
