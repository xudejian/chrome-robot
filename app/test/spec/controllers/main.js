(function() {
  'use strict';
  describe('Controller: MainCtrl', function() {
    var MainCtrl, scope;
    beforeEach(module('chromeRobotApp'));
    MainCtrl = {};
    scope = {};
    beforeEach(inject(function($controller, $rootScope) {
      scope = $rootScope.$new();
      return MainCtrl = $controller('MainCtrl', {
        $scope: scope
      });
    }));
    return it('should attach a list of awesomeThings to the scope', function() {
      return expect(scope.awesomeThings.length).toBe(1);
    });
  });

}).call(this);
