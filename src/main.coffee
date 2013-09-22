connected_rooms = {}
room_ids_order  = []

# TODO: open a tab in the GUI with a DOM id based on id
openTab = (id, name) ->
  console.log 'openTab', id, name
  $('<li>').attr('id', "tab-#{id}")
           .text(name)
           .appendTo('#tabs')

# TODO: close a tab in the GUI with DOM id based on id
closeTab = (id) ->
  console.log 'closeTab', id
  $("#tab-#{id}").remove()

# TODO wire back up to the stuff below the return, populating connected_rooms
# and room_ids_order
connectToRoom = (room) ->
  console.log 'connectToRoom', room
  openTab room.id, room.name

checkRooms = ->
  GET 'presence', (err, res) ->
    if err?
      openAccountSettings()
      window.close()
    else if res.rooms?.length
      connected = {}
      connected[id] = true for id in room_ids_order
      for room in res.rooms
        if connected[room.id]
          delete connected[room.id]
        else
          # open up connections to missing room tabs
          connectToRoom room
      # close extraneous room tabs
      for id of connected
        connected_rooms[id].connection.disconnect()
        delete connected_rooms[id]
        room_ids_order = room_ids_order.filter (oid) -> oid isnt id
    else # no open rooms?  to the selector!
      openRoomSelector()
      window.close()

$(document).ready ->
  $('#add-rooms').click (e) ->
    e.preventDefault()
    openRoomSelector()

  $('#open-settings').click (e) ->
    e.preventDefault()
    openAccountSettings()

  checkRooms()

return # stuff below this not working again yet

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
