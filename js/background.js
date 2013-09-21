(function() {
  chrome.app.runtime.onLaunched.addListener(function() {
    return storage.get(['domain', 'api_key'], function(cfg) {
      if (cfg.domain && cfg.api_key) {
        if (false) {
          return openMainWindow();
        } else {
          return openRoomSelector();
        }
      } else {
        return openAccountSettings();
      }
    });
  });

}).call(this);

/*
//@ sourceMappingURL=background.js.map
*/