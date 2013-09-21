# Tailgate

A Chrome Packaged App client for Campfire

## Flow

    onStartup:
      if accountRegistered
        GET /presence # if times out/fails, open accountSettings instead
        if inAnyRooms
          open mainWindow
        else
          open roomSelector
      else
        open accountSettings

    mainWindow:
      * link to open accountSettings
      * link to open roomSelector
      * link to searchHistory
      * on open checkRooms()
      * can close room tabs
        * POST /room/:id/leave
        * checkRooms()
      checkRooms:
        * GET /presence
        * add/remove tabs as necessary
        * if no rooms left, close mainWindow
        * if new room or on reconnect:
          1. GET /room/:id/recent and display history
          2. GET streaming/room/:id/live to display updates (deduped by msgid)

    accountSettings:
      * displays API key field
      * displays Campfire domain field
      * has [Save] and [Cancel] buttons
      * on Save updates API key and/or Campfire domain if they really changed
      * if changed
          close mainWindow
          close roomSelector
          onStartup()

    roomSelector:
      * List results of GET /rooms - GET /presence
      * spinner/retry button
      * has search box
      * typing in search box live-filters list
      * choosing a room (return or click):
        * closes the roomSelector
        * opens mainWindow if closed,
        * sends mainWindow a checkRooms msg otherwise
