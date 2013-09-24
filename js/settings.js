(function() {
  var defaults, setDevMode,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  defaults = {
    dev_mode: null,
    domain: 'yourdomain',
    token: 'abc123',
    api_base: 'http://localhost:3000',
    streaming_base: 'http://localhost:3000'
  };

  this.settingsController = function($scope) {};

  setDevMode = function() {
    var dev_mode;
    dev_mode = $('#dev_mode')[0].checked;
    return $('#dev').toggleClass('disabled', !dev_mode).find('input').attr('disabled', !dev_mode);
  };

  $(document).ready(function() {
    storage.get(defaults, function(config) {
      var $inp, k, v;
      for (k in config) {
        v = config[k];
        $inp = $("#" + k);
        if (__indexOf.call(bools, k) >= 0) {
          $inp.val(v ? [1] : []);
        } else {
          $inp.val(v);
        }
      }
      return setDevMode();
    });
    $('#dev_mode').change(setDevMode);
    $('#cancel').click(function() {
      return window.close();
    });
    return $('#settings').submit(function(e) {
      var $inp, config, prop;
      e.preventDefault();
      config = {};
      for (prop in defaults) {
        $inp = $("#" + prop);
        config[prop] = __indexOf.call(bools, prop) >= 0 ? $inp[0].checked : $inp.val();
      }
      return storage.set(config, function() {
        setTimeout((function() {
          return window.close();
        }), 0);
        return startupWindows();
      });
    });
  });

}).call(this);

/*
//@ sourceMappingURL=settings.js.map
*/