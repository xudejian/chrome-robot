'use strict'

console.log 'background load'

chrome.runtime.onInstalled.addListener (details) ->
  console.log 'previousVersion', details.previousVersion

HTTP_REQUEST_TIMEOUT = 30 * 1000
HEAD_REQUEST_TIMEOUT = 5 * 1000
RESULTS_TITLE = 'Chrome Robot Work'
SPIDER_MIME = [
  'text/html'
  'text/plain'
  'text/xml'
]

popupDoc = null
allowedText = ''
allowedRegex = null
allowPlusOne = false
allowArguments = false
checkInline = false
checkScripts = false
pagesTodo = {}
pagesDone = {}
spiderTab = null
resultsTab = null
httpRequest = null
httpRequestWatchDogPid = 0
newTabWatchDogPid = 0
started = false
paused = false
currentRequest =
  requestedURL:null
  returnedURL:null
  referrer:null

@popupLoaded = (doc) ->
  console.log 'save popup doc'
  popupDoc = doc
  chrome.tabs.getSelected null, setDefaultUrl_

setDefaultUrl_ = (tab) ->
  if tab and tab.url and tab.url.match /^\s*https?:\/\//i
    url = tab.url
  else
    url = 'http://www.example.com/'

  popupDoc.getElementById('start').value = url

  allowedText = url
  allowedText = trimAfter allowedText, '#'
  allowedText = trimAfter allowedText, '?'
  offset = allowedText.lastIndexOf '/'
  if offset > 'https://'.length
    allowedText = allowedText.substring 0, offset + 1

  allowedText = allowedText.replace /([\^\$\.\*\+\?\=\!\:\|\\\(\)\[\]\{\}])/g, '\\$1'
  allowedText = '^' + allowedText
  popupDoc.getElementById('regex').value = allowedText

  popupDoc.getElementById('plusone').checked = allowPlusOne
  popupDoc.getElementById('arguments').checked = !allowArguments
  popupDoc.getElementById('inline').checked = checkInline
  popupDoc.getElementById('scripts').checked = checkScripts

trimAfter = (string, sep) ->
  offset = string.indexOf sep
  if offset != -1
    return string.substring 0, offset
  string

@popupGo = ->

  console.log 'popupGo'
  popupStop()

  resultsWindows = chrome.extension.getViews type: 'tab'
  console.log resultsWindows

  for x in resultsWindows
    doc = x.document
    console.log 'tab title: ', doc
    if doc.title == RESULTS_TITLE
      console.log x
      doc.title = RESULTS_TITLE + ' - Closed'

  # Attempt to parse the allowed URL regex.
  input = popupDoc.getElementById 'regex'
  allowedText = input.value
  try
    allowedRegex = new RegExp allowedText
  catch e
    alert 'Restrict regex error:\n' + e
    popupStop()
    return

  #Save settings for checkboxes.
  allowPlusOne = popupDoc.getElementById('plusone').checked
  allowArguments = !popupDoc.getElementById('arguments').checked
  checkInline = popupDoc.getElementById('inline').checked
  checkScripts = popupDoc.getElementById('scripts').checked

  # Initialize the todo and done lists.
  pagesTodo = {}
  pagesDone = {}
  # Add the start page to the todo list.
  startPage = popupDoc.getElementById('start').value
  pagesTodo[startPage] = '[root page]'

  resultsLoadCallback_ = (tab) ->
    console.log tab
    resultsTab = tab
    window.setTimeout resultsLoadCallbackDelay_, 100

  resultsLoadCallbackDelay_ = ->
    chrome.tabs.sendMessage resultsTab.id,
      method:"getElementById"
      id:"startingOn"
      action:"setInnerHTML"
      value:setInnerSafely startPage

    chrome.tabs.sendMessage resultsTab.id,
      method:"getElementById"
      id:"restrictTo"
      action:"setInnerHTML"
      value:setInnerSafely allowedText
    # Start spidering.
    started = true
    spiderPage()

  # Open a tab for the results.
  chrome.tabs.create url: 'work.html', resultsLoadCallback_

setInnerSafely = (msg) ->
  msg.toString()
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')

popupStop = ->
  started= false
  pagesTodo = {}
  closeSpiderTab()
  spiderTab = null
  resultsTab = null
  window.clearTimeout httpRequestWatchDogPid
  window.clearTimeout newTabWatchDogPid
  popupDoc.getElementById('robot_go').disabled = false

spiderPage = ->
  console.log 'spiderPage'
  currentRequest =
    requestedURL:null
    returnedURL:null
    referrer:null

  return if paused
  setStatus 'Next page...'
  return unless resultsTab

  # Pull one page URL out of the todo list.
  url = null
  for url in pagesTodo
    break

  unless url
    # Done.
    setStatus 'Complete'
    popupStop()
    return
  # Record page details.
  currentRequest.referrer = pagesTodo[url]
  currentRequest.requestedURL = url
  delete pagesTodo[url]
  pagesDone[url] = true

  # Fetch this page using Ajax.
  setStatus 'Prefetching ' + url
  httpRequestWatchDogPid = window.setTimeout httpRequestWatchDog, HEAD_REQUEST_TIMEOUT
  httpRequest = new XMLHttpRequest()
  httpRequest.onreadystatechange = httpRequestChange
  httpRequest.open 'HEAD', url, false
  # For some reason this request only works intermitently when called directly.
  # Delay request by 1ms.
  window.setTimeout (-> httpRequest.send(null)), 1

httpRequestWatchDog = ->
  console.log("httpRequestWatchDog")
  setStatus('Aborting HTTP Request')
  if httpRequest
    httpRequest.abort()
    # Log your miserable failure.
    currentRequest.returnedURL=null
    recordPage(currentRequest)
    httpRequest = null
  window.setTimeout(spiderPage, 1)

newTabWatchDog = ->
  console.log("newTabWatchDog")
  setStatus('Aborting New Tab')
  closeSpiderTab()

  # Log your miserable failure.
  currentRequest.returnedURL=null
  recordPage(currentRequest)

  window.setTimeout(spiderPage, 1)

httpRequestChange = ->
  console.log("httpRequestChange")

  # Still loading.  Wait for it.
  return if (!httpRequest || httpRequest.readyState < 2)

  code = httpRequest.status
  mime = httpRequest.getResponseHeader('Content-Type') || '[none]'
  httpRequest = null
  window.clearTimeout(httpRequestWatchDogPid)
  setStatus('Prefetched ' + currentRequest.requestedURL + ' (' + mime + ')')

  # 'SPIDER_MIME' is a list of allowed mime types.
  # 'mime' could be in the form of "text/html charset=utf-8"
  # For each allowed mime type, check for its presence in 'mime'.
  mimeOk = false
  for x in SPIDER_MIME
    if mime.indexOf(x) != -1
      mimeOk = true
      break

  # If this is a redirect or an HTML page, open it in a new tab and
  # look for links to follow.  Otherwise, move on to next page.
  is_redirect = ->
    return false unless currentRequest.requestedURL.match allowedRegex
    return true if code >= 300 and code < 400
    return code < 300 and mimeOk
  if is_redirect()
    setStatus('Fetching ' + currentRequest.requestedURL)
    newTabWatchDogPid = window.setTimeout(newTabWatchDog, HTTP_REQUEST_TIMEOUT)
    chrome.tabs.create(
      url: currentRequest.requestedURL
      selected: false
      , spiderLoadCallback_)
  else
    currentRequest.returnedURL = "Skipped"
    recordPage(currentRequest)

    window.setTimeout(spiderPage, 1)

spiderLoadCallback_ = (tab) ->
  spiderTab = tab
  setStatus('Spidering ' + spiderTab.url)
  chrome.tabs.executeScript spiderTab.id, file: 'spider.js'

#Add listener for message events from the injected spider code.
chrome.extension.onMessage.addListener (request, sender, sendResponse) ->
  if 'links' in request
    spiderInjectCallback request.links, request.inline, request.scripts, request.url

  if 'stop' in request
    if started
      if request.stop =="Stopping"
        setStatus("Stopped")
        chrome.tabs.sendMessage resultsTab.id,
          method:"getElementById"
          id:"stopSpider"
          action:"setValue"
          value:"Stopped"
        popupStop()
  if 'pause' in request
    if request.pause =="Resume" && started && !paused
      paused=true
    if request.pause =="Pause" && started && paused
      paused=false
      spiderPage()

spiderInjectCallback = (links, inline, scripts, url) ->
  window.clearTimeout(newTabWatchDogPid)

  setStatus('Scanning ' + url)
  currentRequest.returnedURL = url

  # In the case of a redirect this URL might be different than the one we
  # marked spidered above.  Mark this one as spidered too.
  pagesDone[url] = true

  if checkInline
    links = links.concat(inline)
  if checkScripts
    links = links.concat(scripts)

  # Add any new links to the Todo list.
  for link in links
    link = trimAfter(link, '#')
    if link && !(link in pagesDone) && !(link in pagesTodo)
      if allowArguments || link.indexOf('?') == -1
        if link.match(allowedRegex) || (allowPlusOne && url.match(allowedRegex))
          pagesTodo[link] =url

  # Close this page and mark done.
  recordPage(currentRequest)
  # We want a slight delay before closing as a tab may have scripts loading
  window.setTimeout (-> closeSpiderTab()), 18
  window.setTimeout (-> spiderPage()), 20


closeSpiderTab = ->
  if spiderTab
    chrome.tabs.remove spiderTab.id
    spiderTab = null

recordPage = ->
  if currentRequest.requestedURL != null and currentRequest.returnedURL == null
    codeclass = 'x0'
    currentRequest.returnedURL = "Error"
  cu = currentRequest.requestedURL
  cu = "<a href='#{cu}' target='spiderpage' title='#{cu}'>#{cu}</a>"
  value = '<td>' + cu + '</td>' +
    '<td class="' + codeclass + '"><span title="' + currentRequest.returnedURL + '">' + currentRequest.returnedURL + '</span></td>' +
    '<td><span title="' + currentRequest.referrer + '">' + currentRequest.referrer + '</span></td>'

  chrome.tabs.sendMessage resultsTab.id,
    method:"custom"
    action:"insertResultBodyTR"
    value:value

setStatus = (msg) ->
  return unless started

  try
    chrome.tabs.sendMessage resultsTab.id,
      method:"getElementById"
      id:"stopSpider"
      action:"getValue"
    , (response) ->
      if started and (response == "" || response == null)
        popupStop()
        alert 'Lost access to results pane. Halting.'

    chrome.tabs.sendMessage resultsTab.id,
      method:"getElementById"
      id:"queue"
      action:"setInnerHTML"
      value:Object.keys(pagesTodo).length

    chrome.tabs.sendMessage resultsTab.id,
      method:"getElementById"
      id:"status"
      action:"setInnerHTML"
      value:setInnerSafely(msg)
  catch err
    popupStop()
