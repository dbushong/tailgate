(function() {
  chrome.app.runtime.onLaunched.addListener(function() {
    return GET('/presence', function(err, res) {
      if (err != null) {
        return openAccountSettings();
      } else {
        console.log('/presence', res);
        if (res.rooms.length > 0) {
          return openMainWindow();
        } else {
          return openRoomSelector();
        }
      }
    });
  });

}).call(this);

/*
//@ sourceMappingURL=background.js.map
*/