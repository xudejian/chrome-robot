(function() {
  'use strict';
  describe('Service: site', function() {
    var site;
    beforeEach(module('chromeRobotApp'));
    site = {};
    beforeEach(inject(function(_Site_) {
      return site = _Site_;
    }));
    return it('should do something', function() {
      return expect(!!site).toBe(true);
    });
  });

}).call(this);
