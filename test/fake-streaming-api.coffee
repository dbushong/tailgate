# run with: PORT=whatever coffee fake-streaming-api.coffee

express = require 'express'

app = express()

app.get '/room/:id/live.json', (req, res) ->
  res.send to: 'do'

port = process.env.PORT ? 3000
app.listen port
console.log "Listening on port #{port}"
