$(document).ready ->
  $('#rooms').on 'click', 'li', ->
    id = $(this).data('room-id')
    POST "room/#{id}/join", (err) ->
      if err?
        # FIXME: report somehow
      else
        logger.info "JOINED ROOM #{id}"
        GET 'presence', (err, res) ->
          if err?
            # FIXME: report somehow
          else
            chrome.runtime.sendMessage action: 'joined_room', room_id: id
            openMainWindow() # make sure main window's open
            window.close()

  GET 'rooms', (err, res) ->
    logger.info 'got rooms', res
    if err?
      openAccountSettings()
      window.close()
      return

    # TODO: filter out the ones we're in
    for room in res.rooms
      $('<li>').data('room-id', room.id)
               .text(room.name)
               .appendTo('#rooms')
