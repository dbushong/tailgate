class @CampfireStreamingClient
  constructor: (base, @room_id, @token) ->
    unless m = base.match /^http:\/\/([^\/:]+)(?::(\d+))?/
      throw new Error 'Invalid streaming_base'
    
    @host      = m[1]
    @port      = m[2] ? 80
    @listeners = {}

  # TODO: use EventEmitter somehow?
  on: (ev, fn) ->
    @listeners[ev] ||= []
    @listeners[ev].push fn

  removeListener: (ev, fn) ->
    @listeners[ev] = (@listeners[ev] or []).filter (l) -> l isnt fn

  emit: (ev, what...) ->
    fn what... for fn in (@listeners[ev] or [])

  connect: ->
    @header = @buffer = @chunk = ''
    @chunk_len = null

    @tcp = new TcpClient @host, Number(@port)
    @tcp.addResponseListener @_onData.bind(this)
    @tcp.callbacks.disconnect = @_retry.bind(this)
    @tcp.connect (code) =>
      if code is 0
        @tcp.sendMessage """GET /room/#{@room_id}/live.json HTTP/1.1\r
                            Authorization: Basic #{btoa("#{@token}:x")}\r
                            Host: #{@host}:#{@port}\r
                            Accept: */*\r\n\r\n
                        """
        @emit 'connect'
      else
        @_retry code

  _retry: (code=null) ->
    code = if code? then " (#{code})" else ''
    console.warn "connection failed#{code}; retrying in 5 seconds..."
    @disconnect()
    setTimeout @connect.bind(this), 5e3

  disconnect: ->
    @tcp.disconnect()
    @tcp.callbacks = {}
    chrome.socket.destroy @tcp.socketId

  _onData: (str) ->
    # TODO: mod TcpClient to return bytearray?
    @buffer += unescape encodeURIComponent str

    #console.log 'onData', str

    while @buffer.length > 0
      unless @header
        return unless m = @buffer.match /([\s\S]+?)\r?\n\r?\n([\s\S]*)/
        @header = m[1]
        @buffer = m[2]
        @emit 'header', @header

      if @chunk_len?
        left = @chunk_len - @chunk.length
        @chunk += @buffer[0...left]
        @buffer = @buffer[left..]
        if @chunk.length is @chunk_len
          @buffer = @buffer[2..] # strip off \r\n
          @chunk_len = null
          @_parseMessage decodeURIComponent escape @chunk
          @chunk = ''

      if m = @buffer.match /^([0-9a-f]+)\r\n([\s\S]*)/
        @chunk_len = parseInt m[1], 16
        @buffer = m[2]
      else
        break

  _parseMessage: (str) ->
    #console.info 'CHUNK', str
    for piece in str.split /\r/
      continue unless /\{/.test piece
      try
        @emit 'message', JSON.parse(piece)
      catch e
        console.error "failed to parse JSON: #{piece}"

