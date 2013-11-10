'use strict'

class Robot extends EventEmitter
  HTTP_REQUEST_TIMEOUT = 30 * 1000
  FETCH_IDLE_GAP = 10
  FETCH_BUSY_GAP = 3 * 1000
  FETCH_WAIT_REQ = 3 * 1000

  constructor: (@name, options) ->
    unless @name or @name.length
      throw msg: 'robot should have a name'
    @_ready = false
    @working = false
    @nproc = 1

    @list_todo = []
    @info_todo = []

    @reset_options()
    @options options
    @system_busy false

    @data = {}
    @_data = {}
    chrome.storage.local.get @name, (data) =>
      @_data = data
      data[@name] ?= @data
      @data = data[@name]
      @data.todo ?= {}
      @data.done ?= {}
      chrome.storage.local.set data

      @restore_job @data.todo
      @prepare_from_seed()
      @_ready = true
      @emit 'ready'

  reset_options: ->
    @seeds = []
    @list_re = []
    @info_re = []

  options: (options={}) ->
    @seed (options.seed || [])
    @add_info_re (options.info_regexp || [])
    @add_list_re (options.list_regexp || [])
    @working = if options.stop then false else true

  merge_array = (arr, items) ->
    items = [items] unless Array.isArray items
    indexOf = (arr, item) ->
      item_str = item.toString()
      return i for it,i in arr when it.toString() is item_str
      return -1
    for item in items when -1 is indexOf arr, item
      arr.push item

  add_list_re: (regexp) ->
    regexp = [regexp] unless Array.isArray regexp
    regexps = (utils.smart_regexp(re) for re in regexp)
    merge_array @list_re, regexps

  dump_regexp_list: ->
    console.log "-- info re --"
    console.log i, re.toString() for re, i in @info_re
    console.log "-- list re --"
    console.log i, re.toString() for re, i in @list_re
    return

  add_info_re: (regexp) ->
    regexp = [regexp] unless Array.isArray regexp
    regexps = (utils.smart_regexp(re) for re in regexp)
    merge_array @info_re, regexps

  is_list: (url) ->
    return true for re in @list_re when re.test url

  is_info: (url) ->
    return true for re in @info_re when re.test url

  seed: (seeds) ->
    merge_array @seeds, seeds

  trimAfter = (string, sep) ->
    offset = string.indexOf sep
    if offset isnt -1
      return string.substring 0, offset
    string

  already_todo: (url) ->
    true if @in_done(url) or @in_todo(url)

  add_job_url: (url, referrer) ->
    url = trimAfter url, '#'
    return if @already_todo url
    @add_job
      url: url
      get_url_count: 0
      referrer: referrer
      status: 'queue'

  add_job_seed: (url) ->
    return if @already_todo url
    @add_list_job
      url: url
      get_url_count: 0
      referrer: url
      status: 'seed'

  in_done: (url) ->
    url = url.toLowerCase()
    @data.done.hasOwnProperty url

  fetched: (url) ->
    url = url.toLowerCase()
    @data.done[url] = 1
    delete @data.todo[url]
    chrome.storage.local.set @_data, ->

  in_todo: (url) ->
    url = url.toLowerCase()
    @data.todo.hasOwnProperty url

  add_todo: (url) ->
    url = url.toLowerCase()
    @data.todo[url] = 1
    chrome.storage.local.set @_data, ->

  add_info_job: (job) ->
    @add_todo job.url
    @info_todo.push job
    @emit 'todo.info', job

  add_list_job: (job) ->
    @add_todo job.url
    @list_todo.push job
    @emit 'todo.list', job

  add_job: (job) ->
    if @is_info job.url
      @add_info_job job
    else if @is_list job.url
      @add_list_job job

  restore_job: (todos) ->
    urls = Object.keys todos
    for url in urls
      job =
        url: url
        get_url_count: 0
        status: 'restore'
      if @is_info url
        @add_info_job job
      else if @is_list url
        @add_list_job job

  job_fetch_done: (job, data, status) ->
    @fetched job.url
    @parse_fetched_content job, data

  parse_fetched_content: (job, data) ->
    canfollow = (link) -> link.rel.toLowerCase() isnt 'nofollow'
    doc = utils.world data, job.url
    links = (link.href for link in doc.links when canfollow link)
    job.get_url_count = links.length
    job.content = data
    job.links = links

    @emit 'response', job
    @add_job_url link, job.url for link in links

  do_job_once: (next) ->
    job = @info_todo.shift() || @list_todo.shift()
    return next.call @ unless job
    job.status = 100
    config =
      success: (status, data, headers) =>
        job.status = status
        @job_fetch_done job, data, status
        next.call @
      error: (status) =>
        job.status = status
        if status is 408
          job.retry ?= 2
          job.retry -= 1
          if job.retry > 0
            return @get_web job.url, config
          @emit 'timeout', job
        next.call @
    @get_web job.url, config
    @emit 'request', job

  do_job: ->
    next = =>
      return unless @working
      unless @info_todo.length or @list_todo.length
        return setTimeout next, FETCH_WAIT_REQ
      @do_job_once @do_job
    setTimeout next, @fetch_gap

  prepare_from_seed: ->
    @ready =>
      @add_job_seed url for url in @seeds

  system_busy: (busy) ->
    @_system_busy = not not busy
    @fetch_gap = if busy then FETCH_BUSY_GAP else FETCH_IDLE_GAP

  ready: (cb) ->
    if @_ready
      cb()
    else
      @once 'ready', cb
  start: ->
    @working = true
    @prepare_from_seed()
    @do_job()
    @emit 'start'

  stop: ->
    @working = false
    @emit 'stop'

  clean: ->
    @ready =>
      @data.done = {}
      chrome.storage.local.set @_data
      @emit 'clean'

  get_web: (url, config={}) ->
    config.timeout ?= HTTP_REQUEST_TIMEOUT
    config.success ?= ->
    config.error ?= ->

    xhr = new XMLHttpRequest()
    xhr.onreadystatechange = ->
      if xhr.readyState is 3
        ct = xhr.getResponseHeader("content-type") || "text/html"
        if -1 is ct.indexOf 'text/'
          xhr.abort()
          xhr = null
          config.error 415
      return unless xhr.readyState is 4
      clearTimeout tid
      responseHeaders = xhr.getAllResponseHeaders()
      response = if xhr.responseType then xhr.response else xhr.responseText
      config.success xhr.status, response, responseHeaders
      xhr = null
    xhr.setRequestHeader "Accept", "text/*"
    xhr.timeout = config.timeout
    xhr.open 'GET', url, true
    xhr.send()

    timeout_handle = ->
      return unless xhr
      xhr.abort()
      xhr = null
      config.error 504

    tid = setTimeout timeout_handle, config.timeout + 10

@Robot = Robot
