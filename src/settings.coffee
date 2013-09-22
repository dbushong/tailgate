$(document).ready ->
  defaults =
    domain:         'yourdomain'
    token:          'abc123'
    api_base:       DefaultAPIBase
    streaming_base: DefaultStreamingBase

  storage.get defaults, (config) ->
    for k, v of config
      $("##{k}").val v

  $('#cancel').click -> window.close()

  $('#settings').submit (e) ->
    e.preventDefault()
    config = {}
    config[setting.name] = setting.value for setting in $(this).serializeArray()
    # TODO: check to make sure things have changed before calling .set()?
    storage.set config, ->
      setTimeout (-> window.close()), 0
      startupWindows()
