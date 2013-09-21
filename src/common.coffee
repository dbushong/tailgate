@storage = chrome.storage.local # or chrome.storage.sync

openMainWindow = ->
  chrome.app.window.create 'main.html',
    bounds:
      width: 400
      height: 500

openAccountSettings = ->
  chrome.app.window.create 'settings.html',
    bounds:
      width: 400
      height: 500

openRoomSelector = ->
  chrome.app.window.create 'room-selector.html',
    bounds:
      width: 400
      height: 500
