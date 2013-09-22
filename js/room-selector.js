(function() {
  $(document).ready(function() {
    $('#rooms').on('click', 'li', function() {
      var id;
      id = $(this).data('room-id');
      return POST("room/" + id + "/join", function(err) {
        if (err != null) {

        } else {
          return console.log("JOINED " + id);
        }
      });
    });
    return GET('rooms', function(err, res) {
      var room, _i, _len, _ref, _results;
      console.log(res);
      if (err != null) {
        openAccountSettings();
        window.close();
        return;
      }
      _ref = res.rooms;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        room = _ref[_i];
        _results.push($('<li>').data('room-id', room.id).text(room.name).appendTo('#rooms'));
      }
      return _results;
    });
  });

}).call(this);

/*
//@ sourceMappingURL=room-selector.js.map
*/