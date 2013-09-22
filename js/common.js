(function() {
  var request,
    __slice = [].slice;

  this.storage = chrome.storage.local;

  this.DefaultAPIBase = 'https://$domain.campfirenow.com';

  this.DefaultStreamingBase = 'http://streaming.campfirenow.com';

  this.startupWindows = function() {
    return storage.get(['domain', 'token'], function(config) {
      if (config.domain && config.token) {
        return openMainWindow();
      } else {
        return openAccountSettings();
      }
    });
  };

  this.openMainWindow = function() {
    return chrome.app.window.create('main.html', {
      id: 'main',
      bounds: {
        width: 400,
        height: 500
      }
    });
  };

  this.openAccountSettings = function() {
    return chrome.app.window.create('settings.html', {
      id: 'settings',
      bounds: {
        width: 400,
        height: 500
      }
    });
  };

  this.openRoomSelector = function() {
    return chrome.app.window.create('room-selector.html', {
      id: 'room-selector',
      bounds: {
        width: 400,
        height: 500
      }
    });
  };

  request = function(type, path, cb) {
    return storage.get(null, function(config) {
      var api_base, opts;
      if (!(config.token && config.domain)) {
        return cb('ENOCONFIG');
      }
      api_base = ((config.dev_mode && config.api_base) || DefaultAPIBase).replace(/\$domain/, config.domain);
      opts = {
        username: config.token,
        password: 'X',
        timeout: 5000,
        type: type,
        url: "" + api_base + "/" + path,
        error: function(xhr, status, err) {
          console.error("" + type + " " + path + " error: " + err, {
            status: status,
            xhr: xhr
          });
          return cb(err);
        },
        success: function(res) {
          return cb(null, res);
        }
      };
      if (type === 'GET') {
        opts.dataType = 'json';
      }
      return $.ajax(opts);
    });
  };

  this.GET = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return request.apply(null, ['GET'].concat(__slice.call(args)));
  };

  this.POST = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return request.apply(null, ['POST'].concat(__slice.call(args)));
  };

  this.PUT = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return request.apply(null, ['PUT'].concat(__slice.call(args)));
  };

  this.DELETE = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return request.apply(null, ['DELETE'].concat(__slice.call(args)));
  };

}).call(this);

/*
//@ sourceMappingURL=common.js.map
*/