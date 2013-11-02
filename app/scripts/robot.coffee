'use strict'

class Robot extends EventEmitter
  HTTP_REQUEST_TIMEOUT = 30 * 1000
  FETCH_GAP = 10
  FETCH_WAIT_REQ = 3 * 1000

  constructor: (@name, options) ->
    @working = false
    @nproc = 1

    @done = {}

    @todo = {}
    @list_todo = []
    @info_todo = []

    @reset_options()
    @options options

  reset_options: ->
    @seeds = []
    @list_re = []
    @info_re = []

  options: (options={}) ->
    @seed (options.seed || [])
    @add_info_re (options.info_regexp || [])
    @add_list_re (options.list_regexp || [])
    @prepare_from_seed()

  merge_array = (arr, items) ->
    console.log 'before', arr,items
    items = [items] unless Array.isArray items
    for item in items when -1 is arr.indexOf item
      arr.push item
    console.log 'after', arr

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
      status: 'pending'

  add_job_seed: (url) ->
    return if @already_todo url
    @add_list_job
      url: url
      get_url_count: 0
      referrer: url
      status: 'seed'

  in_done: (url) -> @done.hasOwnProperty url.toLowerCase()
  fetched: (url) ->
    url = url.toLowerCase()
    @done[url] = true
    delete @todo[url] if @todo[url]

  in_todo: (url) -> @todo.hasOwnProperty url.toLowerCase()
  add_todo: (url) -> @todo[url.toLowerCase()] = true

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

  job_fetch_done: (job, data, status) ->
    job.status = status
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
    job.status = 'fetching'
    config =
      success: (status, data, headers) =>
        @job_fetch_done job, data, status
        next.call @
      error: (status) =>
        next.call @
    @get_web job.url, config

  do_job: ->
    next = =>
      return unless @working
      unless @info_todo.length or @list_todo.length
        return setTimeout next, FETCH_WAIT_REQ
      @do_job_once @do_job
    setTimeout next, FETCH_GAP

  prepare_from_seed: ->
    @add_job_seed url for url in @seeds

  start: ->
    @working = true
    @do_job()
    @emit 'start'

  stop: ->
    @working = false
    @emit 'stop'

  get_web: (url, config={}) ->
    config.timeout ?= HTTP_REQUEST_TIMEOUT
    config.success ?= ->
    config.error ?= ->

    xhr = new XMLHttpRequest()
    xhr.onreadystatechange = ->
      return unless xhr.readyState == 4
      clearTimeout tid
      responseHeaders = xhr.getAllResponseHeaders()
      response = if xhr.responseType then xhr.response else xhr.responseText
      config.success xhr.status, response, responseHeaders
      xhr = null
    xhr.open 'GET', url, true
    xhr.send()

    timeout_handle = ->
      return unless xhr
      xhr.abort()
      xhr = null
      config.error 522

    tid = setTimeout timeout_handle, config.timeout

@Robot = Robot
