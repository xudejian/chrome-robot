'use strict'
async.auto
  get_data: (callback) ->
    # async code to get some data
    console.log 'this is get_data'
  make_folder: (callback) ->
    # async code to create a directory to store a file in
    # this is run at the same time as getting the data
    console.log 'make_folder here'
  write_file: [
    'get_data'
    'make_folder'
    (callback) ->
      # once there is some data and the directory exists,
      # write the data to a file in the directory
      callback(null, filename)
      console.log 'this is write_file'
  ]
  email_link: [
    'write_file'
    (callback, results) ->
      # once the file is written let's email a link to it...
      # results.write_file contains the filename returned by write_file.
      console.log 'hi, email_link'
  ]
