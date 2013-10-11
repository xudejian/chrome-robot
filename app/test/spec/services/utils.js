(function() {
  'use strict';
  describe('factory: utils', function() {
    var utils;
    beforeEach(module('chromeRobotApp'));
    utils = {};
    beforeEach(inject(function(_utils_) {
      return utils = _utils_;
    }));
    return it('should been defined service utils', function() {
      return expect(!!utils).toBe(true);
    });
  });

}).call(this);
