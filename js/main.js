(function() {
  var checkRooms, closeConnections, closeTab, connectToRoom, disconnectFromRoom, handleMessage, openTab, room_ids_order, seen_msg;

  seen_msg = {};

  this.connected_rooms = {};

  room_ids_order = [];

  closeConnections = function() {
    var id, room, _results;
    _results = [];
    for (id in connected_rooms) {
      room = connected_rooms[id];
      _results.push(room.connection.disconnect());
    }
    return _results;
  };

  chrome.runtime.onSuspend.addListener(closeConnections);

  openTab = function(id, name) {
    logger.info('openTab', id, name);
    $('<li>').attr('id', "tab-" + id).text(name).appendTo('#tabs');
    return $('<div>').attr('id', "pane-" + id).appendTo('#panes');
  };

  closeTab = function(id) {
    logger.info('closeTab', id);
    $("#tab-" + id).remove();
    return $("#pane-" + id).remove();
  };

  disconnectFromRoom = function(id) {
    closeTab(id);
    connected_rooms[id].connection.disconnect();
    delete connected_rooms[id];
    return room_ids_order = room_ids_order.filter(function(oid) {
      return oid !== id;
    });
  };

  handleMessage = function(msg) {
    if (seen_msg[msg.id]) {
      logger.warn("got dup msg id " + msg.id);
      return;
    }
    seen_msg[msg.id] = true;
    logger.info('RECV MESSAGE', msg);
    return $('<div>').text(JSON.stringify(msg)).appendTo("#pane-" + msg.room_id);
  };

  connectToRoom = function(room) {
    var $pane;
    connected_rooms[room.id] = room;
    room_ids_order.push(room.id);
    $pane = openTab(room.id, room.name);
    return storage.get(null, function(config) {
      var client, streaming_base;
      streaming_base = config.dev_mode ? config.streaming_base : DefaultStreamingBase;
      client = new CampfireStreamingClient(config.streaming_base, room.id, config.token);
      client.on('message', handleMessage);
      client.on('connect', function() {
        return logger.info("streaming room " + room.id);
      });
      client.on('disconnect', function() {
        return logger.info("stopped streaming room " + room.id);
      });
      client.connect();
      return room.connection = client;
    });
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
          _results.push(disconnectFromRoom(id));
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
    chrome.runtime.onMessage.addListener(function(msg) {
      switch (msg.action) {
        case ['joined_room', 'reconfigured']:
          return checkRooms();
      }
    });
    return checkRooms();
  });

}).call(this);

/*
//@ sourceMappingURL=main.js.map
*/