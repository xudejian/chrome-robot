'use strict'

class Robot
  todo = []
  done = {}
  list_re = []
  info_re = []
  HTTP_REQUEST_TIMEOUT = 30 * 1000
  FETCH_GAP = 10

  constructor: (@name, @nproc=1) ->
    @working=false
    @seeds = []

  merge_array = (arr, items) ->
    items = [items] unless Array.isArray items
    arr.push item for item in items when -1 is arr.indexOf item

  add_list_re: (regexp) ->
    merge_array list_re regexp

  add_info_re: (regexp) ->
    merge_array info_re regexp

  seed: (seeds) ->
    merge_array @seeds seeds

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
    msg =
      op: 'todo'
      job: job
    chrome.runtime.sendMessage msg

  job_fetch_done = (job, data, status) ->
    job.status = status
    done[job.url] = true
    parse_fetched_content job, data

  parse_fetched_content = (job, data) ->
    job.links = utils.url.urls utils.world data, job.url
    job.get_url_count = job.links.length

    msg =
      op: 'fetched'
      job: job
    chrome.runtime.sendMessage msg

    add_job_url link, job.url for link in job.links

  do_job_once = (next) ->
    job = todo.shift()
    job.status = 'fetching'
    config =
      success: (status, data, headers) ->
        next()
        job_fetch_done job, data, status
      error: (status) ->
        next()
    get_web job.url, config

  do_job = ->
    next = ->
      return unless @working or todo.length
      do_job_once do_job
    setTimeout next, FETCH_GAP

  prepare_from_seed: ->
    add_job_url url, url for url in @seeds

  start: ->
    @working = true
    do_job()

  stop: ->
    @working = false

  get_web = (url, config={}) ->
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
