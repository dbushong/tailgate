(function() {
  chrome.app.runtime.onLaunched.addListener(startupWindows);

  chrome.runtime.onMessage.addListener(function(msg, sender) {
    if (msg.action === 'log') {
      return console[msg.level].apply(console, msg.log);
    }
  });

}).call(this);

/*
//@ sourceMappingURL=background.js.map
*/