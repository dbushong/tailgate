@storage = chrome.storage.local # or chrome.storage.sync

@DefaultAPIBase       = 'https://$domain.campfirenow.com'
@DefaultStreamingBase = 'http://streaming.campfirenow.com'
# FIXME: if we come up with a better streaming solution, we can use 
# https for streaming again

log = (level, args) ->
  chrome.runtime.sendMessage action: 'log', log: args, level: level
@logger = {}
for level in ['info', 'warn', 'error', 'log']
  @logger[level] = (args...) -> log level, args

@startupWindows = ->
  storage.get ['domain', 'token'], (config) ->
    if config.domain and config.token
      openMainWindow()
    else
      openAccountSettings()

@openMainWindow = ->
  chrome.app.window.create 'main.html',
    id: 'main'
    bounds:
      width: 400
      height: 500

@openAccountSettings = ->
  chrome.app.window.create 'settings.html',
    id: 'settings'
    bounds:
      width: 400
      height: 500

@openRoomSelector = ->
  chrome.app.window.create 'room-selector.html',
    id: 'room-selector'
    bounds:
      width: 400
      height: 500

# doesn't work from background.coffee; it has no jQuery loaded
request = (type, path, cb) ->
  storage.get null, (config) ->
    return cb 'ENOCONFIG' unless config.token and config.domain

    api_base = ((config.dev_mode and config.api_base) or DefaultAPIBase)
      .replace(/\$domain/, config.domain)

    opts =
      timeout:  5000
      type:     type
      url:      "#{api_base}/#{path}"
      error: (xhr, status, err) ->
        logger.error "#{type} #{path} error: #{err}", { status, xhr }
        cb err
      success: (res) -> cb null, res
      beforeSend: (xhr) ->
        auth_hdr = "Basic #{btoa("#{config.token}:X")}"
        xhr.setRequestHeader 'Authorization', auth_hdr

    # campfire API tends to return "OK" for modifying API calls
    opts.dataType = 'json' if type is 'GET'

    $.ajax opts

@GET    = (args...) -> request 'GET',    args...
@POST   = (args...) -> request 'POST',   args...
@PUT    = (args...) -> request 'PUT',    args...
@DELETE = (args...) -> request 'DELETE', args...
