(function() {
  var config, connect, default_config, handleMessage, seen;

  default_config = {
    host: 'localhost',
    port: 3000,
    room_id: 1,
    token: 'abc'
  };

  config = {};

  seen = {};

  handleMessage = function(msg) {
    if (seen[msg.id]) {
      console.warn("got dup msg id " + msg.id);
      return;
    }
    seen[msg.id] = true;
    return console.log(msg);
  };

  connect = function() {
    var client;
    client = new CampfireStreamingClient(config.host, config.port, config.room_id, config.token);
    client.on('message', handleMessage);
    client.on('connect', function() {
      return console.info('connected to server');
    });
    client.on('disconnect', function() {
      return console.info('disconnected from server');
    });
    client.connect();
    return client;
  };

  storage.get(default_config, function(res) {
    var client, prop, val;
    for (prop in res) {
      val = res[prop];
      config[prop] = val;
      document.getElementById(prop).value = val;
    }
    client = connect();
    document.getElementById('config').addEventListener('submit', function(e) {
      e.preventDefault();
      for (prop in config) {
        config[prop] = document.getElementById(prop).value;
      }
      return storage.set(config, function() {
        var client2;
        client2 = connect();
        client.disconnect();
        return client = client2;
      });
    });
    return chrome.runtime.onSuspend.addListener(function() {
      return client.disconnect();
    });
  });

}).call(this);

/*
//@ sourceMappingURL=main.js.map
*/