@storage = chrome.storage.local # or chrome.storage.sync

@openMainWindow = ->
  chrome.app.window.create 'main.html',
    bounds:
      width: 400
      height: 500

@openAccountSettings = ->
  chrome.app.window.create 'settings.html',
    bounds:
      width: 400
      height: 500

@openRoomSelector = ->
  chrome.app.window.create 'room-selector.html',
    bounds:
      width: 400
      height: 500

request = (type, path, cb) ->
  storage.get ['api_key', 'domain'], (config) ->
    return cb 'ENOCONFIG' unless config.api_key and config.domain

    $.ajax
      dataType: 'json'
      username: config.api_key
      password: 'X'
      timeout:  5000
      type:     type
      url:      "https://#{config.domain}.campfirenow.com#{path}.json"
      error: (xhr, status, err) ->
        console.error "#{type} #{path} error: #{err}", { status, xhr }
        cb err
      success: (res) -> cb null, res

@GET    = (args...) -> request 'GET',    args...
@POST   = (args...) -> request 'POST',   args...
@PUT    = (args...) -> request 'PUT',    args...
@DELETE = (args...) -> request 'DELETE', args...
