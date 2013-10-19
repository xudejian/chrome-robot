'use strict'

class Robot
  todo = []
  done = {}
  currentRequest =
    requestedURL:null
    returnedURL:null
    referrer:null
  HTTP_REQUEST_TIMEOUT = 30 * 1000
  HEAD_REQUEST_TIMEOUT = 5 * 1000
  MIME = [
    'text/html'
    'text/plain'
    'text/xml'
  ]

  constructor: (@name, @$http, @working=true) ->

  seed: (@seeds) ->

  trimAfter = (string, sep) ->
    offset = string.indexOf sep
    if offset != -1
      return string.substring 0, offset
    string

  add_job_url = (url, referrer) ->
    add_job
      url: url
      get_url_count: 0
      referrer: referrer
      status: 'pending'
  add_job = (job) ->
    job.url = trimAfter job.url, '#'
    return if done[job.url]
    todo.push job

  job_fetch_done = (job, data, status) ->
    job.status = status
    done[job.url] = true
    parse_fetched_content job, data

  parse_fetched_content = (job, data) ->
    job.document = utils.world data, job.url
    job.links = utils.url.urls job.document
    job.get_url_count = job.links.length

    add_job_url link, job.url for link in job.links

  do_job_once: ->
    job = todo.shift()
    job.status = 'fetching'
    @$http.get(job.url)
      .success (data, status) ->
        job_fetch_done job, data, status

  prepare_from_seed: ->
    add_job_url url, url for url in @seeds

  start: ->
    @working = false
    while @working and todo.length
      do_job_once()

  stop: ->
    @working = true

  httpRequestChange = ->
    return if (!httpRequest || httpRequest.readyState < 2)

    code = httpRequest.status
    mime = httpRequest.getResponseHeader('Content-Type') || '[none]'
    httpRequest = null
    clearTimeout(httpRequestWatchDogPid)
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
      newTabWatchDogPid = setTimeout(newTabWatchDog, HTTP_REQUEST_TIMEOUT)
      chrome.tabs.create(
        url: currentRequest.requestedURL
        selected: false
        , spiderLoadCallback_)
    else
      currentRequest.returnedURL = "Skipped"
      recordPage(currentRequest)

      setTimeout(spiderPage, 1)

  get_web: (url, config) ->
    xhr = new XMLHttpRequest()
    xhr.onreadystatechange = ->
      if xhr.readyState == 4
        responseHeaders = xhr.getAllResponseHeaders()

        completeRequest(callback,
            status || xhr.status,
            (xhr.responseType ? xhr.response : xhr.responseText),
            responseHeaders)
    xhr.open 'GET', url, true
    xhr.send()

popupStop = ->
  clearTimeout httpRequestWatchDogPid
  clearTimeout newTabWatchDogPid

spiderPage = ->
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
  httpRequestWatchDogPid = setTimeout httpRequestWatchDog, HEAD_REQUEST_TIMEOUT
  httpRequest = new XMLHttpRequest()
  httpRequest.onreadystatechange = httpRequestChange
  httpRequest.open 'HEAD', url, false
  setTimeout (-> httpRequest.send(null)), 0

httpRequestWatchDog = ->
  setStatus('Aborting HTTP Request')
  if httpRequest
    httpRequest.abort()
    # Log your miserable failure.
    currentRequest.returnedURL=null
    recordPage(currentRequest)
    httpRequest = null
  setTimeout spiderPage, 0

newTabWatchDog = ->
  setStatus('Aborting New Tab')
  closeSpiderTab()

  # Log your miserable failure.
  currentRequest.returnedURL=null
  recordPage(currentRequest)

  setTimeout spiderPage, 0

spiderInjectCallback = (links, inline, scripts, url) ->
  clearTimeout(newTabWatchDogPid)

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
  setTimeout (-> closeSpiderTab()), 18
  setTimeout (-> spiderPage()), 20
