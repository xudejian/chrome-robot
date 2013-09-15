'use strict'
async.auto
  get_data: (callback) ->
    console.log 'this is get_data'
    # async code to get some data
    callback null, 'get_data_success'
  make_folder: (callback) ->
    console.log 'make_folder here'
    # async code to create a directory to store a file in
    # this is run at the same time as getting the data
    callback null, 'make_folder_success'
  write_file: [
    'get_data'
    'make_folder'
    (callback) ->
      console.log 'this is write_file'
      # once there is some data and the directory exists,
      # write the data to a file in the directory
      callback 'write_file_fail', 'write_file success'
  ]
  email_link: [
    'write_file'
    (callback, results) ->
      console.log results, 'hi, email_link'
      # once the file is written let's email a link to it...
      # results.write_file contains the filename returned by write_file.
  ]
