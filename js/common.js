(function() {
  var request,
    __slice = [].slice;

  this.storage = chrome.storage.local;

  this.openMainWindow = function() {
    return chrome.app.window.create('main.html', {
      bounds: {
        width: 400,
        height: 500
      }
    });
  };

  this.openAccountSettings = function() {
    return chrome.app.window.create('settings.html', {
      bounds: {
        width: 400,
        height: 500
      }
    });
  };

  this.openRoomSelector = function() {
    return chrome.app.window.create('room-selector.html', {
      bounds: {
        width: 400,
        height: 500
      }
    });
  };

  request = function(type, path, cb) {
    return storage.get(['api_key', 'domain'], function(config) {
      if (!(config.api_key && config.domain)) {
        return cb('ENOCONFIG');
      }
      return $.ajax({
        dataType: 'json',
        username: config.api_key,
        password: 'X',
        timeout: 5000,
        type: type,
        url: "https://" + config.domain + ".campfirenow.com" + path + ".json",
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
      });
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