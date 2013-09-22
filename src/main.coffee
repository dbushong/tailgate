seen_msg        = {} # TODO: use a cycle buffer of some kind?
@connected_rooms = {}
room_ids_order  = []

closeConnections = ->
  for id, room of connected_rooms
    room.connection.disconnect()

chrome.runtime.onSuspend.addListener closeConnections

# returns pane jquery obj
openTab = (id, name) ->
  logger.info 'openTab', id, name
  $('<li>').attr('id', "tab-#{id}")
           .text(name)
           .appendTo('#tabs')
  $('<div>').attr('id', "pane-#{id}").appendTo('#panes')

# TODO: close a tab in the GUI with DOM id based on id
closeTab = (id) ->
  logger.info 'closeTab', id
  $("#tab-#{id}").remove()
  $("#pane-#{id}").remove()

disconnectFromRoom = (id) ->
  closeTab id
  connected_rooms[id].connection.disconnect()
  delete connected_rooms[id]
  room_ids_order = room_ids_order.filter (oid) -> oid isnt id

handleMessage = (msg) ->
  if seen_msg[msg.id]
    logger.warn "got dup msg id #{msg.id}"
    return

  seen_msg[msg.id] = true

  logger.info 'RECV MESSAGE', msg
  $('<div>').text(JSON.stringify(msg)).appendTo("#pane-#{msg.room_id}")

connectToRoom = (room) ->
  connected_rooms[room.id] = room
  room_ids_order.push room.id
  $pane = openTab room.id, room.name

  storage.get null, (config) ->
    streaming_base =
      if config.dev_mode then config.streaming_base else DefaultStreamingBase
    client = new CampfireStreamingClient(
      config.streaming_base, room.id, config.token)
    client.on 'message', handleMessage
    client.on 'connect', -> logger.info "streaming room #{room.id}"
    client.on 'disconnect', -> logger.info "stopped streaming room #{room.id}"
    client.connect()
    room.connection = client

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
      disconnectFromRoom id for id of connected
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

  chrome.runtime.onMessage.addListener (msg) ->
    switch msg.action
      when ['joined_room', 'reconfigured'] then checkRooms()

  checkRooms()
