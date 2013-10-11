(function() {
  'use strict';
  var chrome;

  window.chrome = chrome = {
    storage: {
      local: {
        get: function() {},
        set: function() {}
      },
      sync: {
        get: function() {},
        set: function() {}
      }
    }
  };

  angular.module('mockedChrome', []).value('chrome', chrome);

}).call(this);
