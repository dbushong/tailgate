(function() {
  var level, log, request, _i, _len, _ref,
    __slice = [].slice;

  this.storage = chrome.storage.local;

  this.DefaultAPIBase = 'https://$domain.campfirenow.com';

  this.DefaultStreamingBase = 'https://streaming.campfirenow.com';

  log = function(level, args) {
    return chrome.runtime.sendMessage({
      action: 'log',
      log: args,
      level: level
    });
  };

  this.logger = {};

  _ref = ['info', 'warn', 'error', 'log'];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    level = _ref[_i];
    this.logger[level] = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return log(level, args);
    };
  }

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
        timeout: 5000,
        type: type,
        url: "" + api_base + "/" + path,
        error: function(xhr, status, err) {
          logger.error("" + type + " " + path + " error: " + err, {
            status: status,
            xhr: xhr
          });
          return cb(err);
        },
        success: function(res) {
          return cb(null, res);
        },
        beforeSend: function(xhr) {
          var auth_hdr;
          auth_hdr = "Basic " + (btoa("" + config.token + ":X"));
          return xhr.setRequestHeader('Authorization', auth_hdr);
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