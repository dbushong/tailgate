chrome.app.runtime.onLaunched.addListener startupWindows

# for some reason onLaunched() doesn't always fire, so sticking this out
# here for now

# logging aggregator TODO: figure out how to include sender in log line?
chrome.runtime.onMessage.addListener (msg, sender) ->
  if msg.action is 'log'
    console.info msg.log...
