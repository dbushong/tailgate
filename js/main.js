(function() {
  var checkRooms, closeTab, connect, connectToRoom, connected_rooms, handleMessage, openTab, room_ids_order, seen;

  connected_rooms = {};

  room_ids_order = [];

  openTab = function(id, name) {
    console.log('openTab', id, name);
    return $('<li>').attr('id', "tab-" + id).text(name).appendTo('#tabs');
  };

  closeTab = function(id) {
    console.log('closeTab', id);
    return $("#tab-" + id).remove();
  };

  connectToRoom = function(room) {
    console.log('connectToRoom', room);
    return openTab(room.id, room.name);
  };

  checkRooms = function() {
    return GET('presence', function(err, res) {
      var connected, id, room, _i, _j, _len, _len1, _ref, _ref1, _results;
      if (err != null) {
        openAccountSettings();
        return window.close();
      } else if ((_ref = res.rooms) != null ? _ref.length : void 0) {
        connected = {};
        for (_i = 0, _len = room_ids_order.length; _i < _len; _i++) {
          id = room_ids_order[_i];
          connected[id] = true;
        }
        _ref1 = res.rooms;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          room = _ref1[_j];
          if (connected[room.id]) {
            delete connected[room.id];
          } else {
            connectToRoom(room);
          }
        }
        _results = [];
        for (id in connected) {
          connected_rooms[id].connection.disconnect();
          delete connected_rooms[id];
          _results.push(room_ids_order = room_ids_order.filter(function(oid) {
            return oid !== id;
          }));
        }
        return _results;
      } else {
        openRoomSelector();
        return window.close();
      }
    });
  };

  $(document).ready(function() {
    $('#add-rooms').click(function(e) {
      e.preventDefault();
      return openRoomSelector();
    });
    $('#open-settings').click(function(e) {
      e.preventDefault();
      return openAccountSettings();
    });
    return checkRooms();
  });

  return;

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