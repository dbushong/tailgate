defaults =
  dev_mode:       null
  domain:         'yourdomain'
  token:          'abc123'
  api_base:       'http://localhost:3000'
  streaming_base: 'http://localhost:3000'

bools = ['dev_mode']

setDevMode = ->
  dev_mode = $('#dev_mode')[0].checked
  $('#dev').toggleClass('disabled', not dev_mode)
           .find('input')
             .attr('disabled', not dev_mode)

$(document).ready ->

  storage.get defaults, (config) ->
    for k, v of config
      $inp = $("##{k}")
      if k in bools
        $inp.val(if v then [1] else [])
      else
        $inp.val v
    setDevMode()

  $('#dev_mode').change setDevMode

  $('#cancel').click -> window.close()

  $('#settings').submit (e) ->
    e.preventDefault()
    config = {}
    for prop of defaults
      $inp = $("##{prop}")
      config[prop] = if prop in bools then $inp[0].checked else $inp.val()
    # TODO: check to make sure things have changed before calling .set()?
    storage.set config, ->
      setTimeout (-> window.close()), 0
      startupWindows()
