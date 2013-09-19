host    = 'localhost'
port    = 3000
room_id = 1
token   = 'abc'

tcp = new TcpClient host, port

header     = ''
buffer     = ''
chunk      = ''
chunk_len  = null

handleMessage = (msg) ->
  console.log msg

parseMessage = (str) ->
  console.info 'CHUNK', str
  for piece in str.split /\r/
    continue unless /\{/.test piece
    try
      handleMessage JSON.parse piece
    catch e
      console.error "failed to parse JSON: #{piece}"

tcp.addResponseListener (str) ->
  # TODO: mod TcpClient to return bytearray?
  buffer += unescape encodeURIComponent str

  while buffer.length > 0
    unless header
      return unless m = buffer.match /([\s\S]+?)\r?\n\r?\n([\s\S]*)/
      header = m[1]
      buffer = m[2]
      #console.info 'HEADER', header

    if chunk_len?
      left = chunk_len - chunk.length
      chunk += buffer[0...left]
      buffer = buffer[left..]
      if chunk.length is chunk_len
        buffer = buffer[2..] # strip off \r\n
        chunk_len = null
        parseMessage decodeURIComponent escape chunk
        chunk = ''

    if m = buffer.match /^([0-9a-f]+)\r\n([\s\S]*)/
      chunk_len = parseInt m[1], 16
      buffer = m[2]
    else
      break

tcp.connect ->
  tcp.sendMessage """GET /room/#{room_id}/live.json HTTP/1.1\r
                     Authorization: Basic #{btoa("#{token}:x")}\r
                     Host: #{host}:#{port}\r
                     Accept: */*\r\n\r\n
                  """
