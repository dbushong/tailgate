chrome.app.runtime.onLaunched.addListener ->
  GET '/presence', (err, res) ->
    if err?
      openAccountSettings()
    else
      console.log '/presence', res
      if res.rooms.length > 0
        openMainWindow()
      else
        openRoomSelector()
