'use strict'
require = (src) ->
  console.log src
  ga = document.createElement 'script'
  ga.type = 'text/javascript'
  ga.src = src
  document.body.appendChild ga

loads = [
  'scripts': [
    'app'
    'route'
  ]
,
  'scripts/services': [
    'utils'
    'config'
    'site'
  ]
,
  'scripts/controllers': [
    'main'
    'site'
    'work'
  ]
,
  'test/mock': [
    'chrome'
  ]
,
  'test/spec': [
    'test'
    'services/utils'
    'services/config'
  ]
]

to_file = (path, file) -> "#{path}/#{file}.js"

for load in loads
  for path, files of load
    for file in files
      require to_file(path, file)

window.setTimeout (-> mocha.run()), 100
