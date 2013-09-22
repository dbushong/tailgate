$(document).ready ->
  $('#rooms').on 'click', 'li', ->
    id = $(this).data('room-id')
    POST "room/#{id}/join", (err) ->
      if err?
        # report somehow
      else
        # TODO: message the main window to run checkRooms() again
        console.log "JOINED #{id}"

  GET 'rooms', (err, res) ->
    console.log res
    if err?
      openAccountSettings()
      window.close()
      return

    # TODO: filter out the ones we're in
    for room in res.rooms
      $('<li>').data('room-id', room.id)
               .text(room.name)
               .appendTo('#rooms')
