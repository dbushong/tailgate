default_config =
  host:     'localhost'
  port:     3000
  room_id:  1
  token:    'abc'

config = {}

seen = {} # TODO: use a cycle buffer of some kind?
handleMessage = (msg) ->
  if seen[msg.id]
    console.warn "got dup msg id #{msg.id}"
    return

  seen[msg.id] = true

  # DO STUFF HERE
  console.log msg

connect = ->
  client = new CampfireStreamingClient(
    config.host, config.port, config.room_id, config.token)
  client.on 'message', handleMessage
  client.on 'connect', -> console.info 'connected to server'
  client.on 'disconnect', -> console.info 'disconnected from server'
  client.connect()
  client

storage.get default_config, (res) ->
  for prop, val of res
    config[prop] = val
    document.getElementById(prop).value = val

  client = connect()
  document.getElementById('config').addEventListener 'submit', (e) ->
    e.preventDefault()
    for prop of config
      config[prop] = document.getElementById(prop).value
    storage.set config, ->
      client2 = connect()
      client.disconnect()
      client = client2

  chrome.runtime.onSuspend.addListener -> client.disconnect()
