(function() {
  $(document).ready(function() {
    var defaults;
    defaults = {
      domain: 'yourdomain',
      token: 'abc123',
      api_base: DefaultAPIBase,
      streaming_base: DefaultStreamingBase
    };
    storage.get(defaults, function(config) {
      var k, v, _results;
      _results = [];
      for (k in config) {
        v = config[k];
        _results.push($("#" + k).val(v));
      }
      return _results;
    });
    $('#cancel').click(function() {
      return window.close();
    });
    return $('#settings').submit(function(e) {
      var config, setting, _i, _len, _ref;
      e.preventDefault();
      config = {};
      _ref = $(this).serializeArray();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        setting = _ref[_i];
        config[setting.name] = setting.value;
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