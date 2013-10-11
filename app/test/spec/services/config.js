(function() {
  'use strict';
  describe('Service: config', function() {
    var config;
    beforeEach(module('chromeRobotApp'));
    config = {};
    beforeEach(inject(function(_config_) {
      return config = _config_;
    }));
    it('should been defined service config', function() {
      return expect(!!config).toBe(true);
    });
    return describe('api: config.site', function() {
      return it('should have a function site to load/set robot site config', function() {
        return expect(config.sites).toBeDefined();
      });
    });
  });

}).call(this);
