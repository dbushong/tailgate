(function() {
  var openAccountSettings, openMainWindow, openRoomSelector;

  this.storage = chrome.storage.local;

  openMainWindow = function() {
    return chrome.app.window.create('main.html', {
      bounds: {
        width: 400,
        height: 500
      }
    });
  };

  openAccountSettings = function() {
    return chrome.app.window.create('settings.html', {
      bounds: {
        width: 400,
        height: 500
      }
    });
  };

  openRoomSelector = function() {
    return chrome.app.window.create('room-selector.html', {
      bounds: {
        width: 400,
        height: 500
      }
    });
  };

}).call(this);

/*
//@ sourceMappingURL=common.js.map
*/