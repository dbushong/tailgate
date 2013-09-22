(function() {
  var __slice = [].slice;

  this.CampfireStreamingClient = (function() {
    function CampfireStreamingClient(base, room_id, token) {
      var m, _ref;
      this.room_id = room_id;
      this.token = token;
      if (!(m = base.match(/^http:\/\/([^\/:]+)(?::(\d+))?/))) {
        throw new Error('Invalid streaming_base');
      }
      this.host = m[1];
      this.port = (_ref = m[2]) != null ? _ref : 80;
      this.listeners = {};
    }

    CampfireStreamingClient.prototype.on = function(ev, fn) {
      var _base;
      (_base = this.listeners)[ev] || (_base[ev] = []);
      return this.listeners[ev].push(fn);
    };

    CampfireStreamingClient.prototype.removeListener = function(ev, fn) {
      return this.listeners[ev] = (this.listeners[ev] || []).filter(function(l) {
        return l !== fn;
      });
    };

    CampfireStreamingClient.prototype.emit = function() {
      var ev, fn, what, _i, _len, _ref, _results;
      ev = arguments[0], what = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      _ref = this.listeners[ev] || [];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        fn = _ref[_i];
        _results.push(fn.apply(null, what));
      }
      return _results;
    };

    CampfireStreamingClient.prototype.connect = function() {
      var _this = this;
      this.header = this.buffer = this.chunk = '';
      this.chunk_len = null;
      this.tcp = new TcpClient(this.host, Number(this.port));
      this.tcp.addResponseListener(this._onData.bind(this));
      this.tcp.callbacks.disconnect = this._retry.bind(this);
      return this.tcp.connect(function(code) {
        if (code === 0) {
          _this.tcp.sendMessage("GET /room/" + _this.room_id + "/live.json HTTP/1.1\r\nAuthorization: Basic " + (btoa("" + _this.token + ":x")) + "\r\nHost: " + _this.host + ":" + _this.port + "\r\nAccept: */*\r\n\r\n");
          return _this.emit('connect');
        } else {
          return _this._retry(code);
        }
      });
    };

    CampfireStreamingClient.prototype._retry = function(code) {
      if (code == null) {
        code = null;
      }
      code = code != null ? " (" + code + ")" : '';
      console.warn("connection failed" + code + "; retrying in 5 seconds...");
      this.disconnect();
      return setTimeout(this.connect.bind(this), 5e3);
    };

    CampfireStreamingClient.prototype.disconnect = function() {
      this.tcp.disconnect();
      this.tcp.callbacks = {};
      return chrome.socket.destroy(this.tcp.socketId);
    };

    CampfireStreamingClient.prototype._onData = function(str) {
      var left, m;
      this.buffer += unescape(encodeURIComponent(str));
      while (this.buffer.length > 0) {
        if (!this.header) {
          if (!(m = this.buffer.match(/([\s\S]+?)\r?\n\r?\n([\s\S]*)/))) {
            return;
          }
          this.header = m[1];
          this.buffer = m[2];
          this.emit('header', this.header);
        }
        if (this.chunk_len != null) {
          left = this.chunk_len - this.chunk.length;
          this.chunk += this.buffer.slice(0, left);
          this.buffer = this.buffer.slice(left);
          if (this.chunk.length === this.chunk_len) {
            this.buffer = this.buffer.slice(2);
            this.chunk_len = null;
            this._parseMessage(decodeURIComponent(escape(this.chunk)));
            this.chunk = '';
          }
        }
        if (m = this.buffer.match(/^([0-9a-f]+)\r\n([\s\S]*)/)) {
          this.chunk_len = parseInt(m[1], 16);
          this.buffer = m[2];
        } else {
          break;
        }
      }
    };

    CampfireStreamingClient.prototype._parseMessage = function(str) {
      var e, piece, _i, _len, _ref, _results;
      _ref = str.split(/\r/);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        piece = _ref[_i];
        if (!/\{/.test(piece)) {
          continue;
        }
        try {
          _results.push(this.emit('message', JSON.parse(piece)));
        } catch (_error) {
          e = _error;
          _results.push(console.error("failed to parse JSON: " + piece));
        }
      }
      return _results;
    };

    return CampfireStreamingClient;

  })();

}).call(this);

/*
//@ sourceMappingURL=campfire-streaming-client.js.map
*/