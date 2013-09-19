# run with: PORT=whatever coffee fake-streaming-api.coffee

express = require 'express'

utcNow = -> (new Date).toISOString()

last_update = {}

sendTimestamps = (room_id, res, msg) ->
  sendTimestamp = ->
    now = utcNow()
    last_update[room_id] = now
    res.write JSON.stringify(
      room_id:    room_id
      created_at: now
      body:       null
      id:         msg.id++
      user_id:    null
      type:       'TimestampMessage'
      starred:    false
    ) + '\r\n'

  int = setInterval sendTimestamp, 5*60e3
  res.on 'close', -> clearInterval(int)

sendMessages = (room_id, res, msg) ->
  return if msg.closed

  user_id = Math.floor(Math.random() * 10) + 1
  now     = utcNow()

  res.write JSON.stringify(
    room_id:    room_id
    created_at: utcNow()
    body:       "User #{user_id} says something at #{now}"
    id:         msg.id++
    user_id:    user_id
    type:       'TextMessage' # TODO: add more types
    starred:    Math.random() > 0.99
  ) + '\r\n'

  setTimeout (-> sendMessages room_id, res, msg), Math.random()*25e3+5e3


app = express()
app.use express.logger()

app.get '/room/:id/live.json', (req, res) ->
  msg = id: 1
  room_id = req.params.id
  sendMessages room_id, res, msg
  sendTimestamps room_id, res, msg
  res.on 'close', -> msg.closed = true

app.get '/room/:id', (req, res) ->
  id = req.params.id
  epoch = '1970-01-01 00:00:00'

  res.send
    room:
      created_at: epoch
      id: id
      membership_limit: 999
      name: "Room #{id}"
      topic: "Room Topic #{id}"
      updated_at: last_update[id] or epoch
      open_to_guests: false
      full: false
      users: [1..10].map (n) ->
        admin: false
        created_at: epoch
        email_address: "#{n}@example.com"
        id: n
        name: "User #{n}"
        type: 'Member'

app.post '/room/:id/join', (req, res) -> res.send 200

port = process.env.PORT ? 3000
app.listen port
console.log "Listening on port #{port}"
