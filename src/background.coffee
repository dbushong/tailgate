chrome.app.runtime.onLaunched.addListener ->
  storage.get ['domain', 'api_key'], (cfg) ->
    if cfg.domain and cfg.api_key
      # GET /presence with timeout resulting in openAccountSettings()
      if false # in AnyRooms
        openMainWindow()
      else
        openRoomSelector()
    else
      openAccountSettings()
