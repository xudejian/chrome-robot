(function() {
  'use strict';
  var file, files, load, loads, path, require, to_file, _i, _j, _len, _len1;

  require = function(src) {
    var ga;
    console.log(src);
    ga = document.createElement('script');
    ga.type = 'text/javascript';
    ga.src = src;
    return document.body.appendChild(ga);
  };

  loads = [
    {
      'scripts': ['app', 'route']
    }, {
      'scripts/services': ['utils', 'config', 'site']
    }, {
      'scripts/controllers': ['main', 'site', 'work']
    }, {
      'test/mock': ['chrome']
    }, {
      'test/spec': ['test', 'services/utils', 'services/config']
    }
  ];

  to_file = function(path, file) {
    return "" + path + "/" + file + ".js";
  };

  for (_i = 0, _len = loads.length; _i < _len; _i++) {
    load = loads[_i];
    for (path in load) {
      files = load[path];
      for (_j = 0, _len1 = files.length; _j < _len1; _j++) {
        file = files[_j];
        require(to_file(path, file));
      }
    }
  }

  window.setTimeout((function() {
    return mocha.run();
  }), 100);

}).call(this);
