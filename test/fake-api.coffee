# run with: PORT=whatever coffee fake-streaming-api.coffee

express = require 'express'

app = express()
app.use express.logger()
app.use express.static(__dirname + '/public')
app.use express.favicon()

fiveMin = (ms) ->
  d = new Date ms
  d.setMinutes      Math.floor(d.getMinutes() / 5) * 5
  d.setSeconds      0
  d.setMilliseconds 0
  d

cfDate = (d) ->
  d.toISOString().replace(/T/, ' ').replace(/-/g, '/').replace(/\..+/, ' +0000')

msg_id      = 1
last_update = {}
app.get '/room/:id/live.json', (req, res) ->
  msg     = id: 1
  room_id = req.params.id
  int     = setInterval (-> res.write ' '), 3e3
  timer   = null

  req.on 'close', ->
    clearTimeout timer if timer
    clearInterval int
    console.info "[room #{room_id}] closed connection"

  do sendMessages = ->
    user_id = Math.floor(Math.random() * 10) + 1
    now     = new Date
    buffer  = ''

    fmnow = fiveMin now
    if fiveMin(last_update[room_id] or 0) < fmnow
      fmnow_str = cfDate fmnow
      buffer = JSON.stringify(
        room_id:    room_id
        created_at: fmnow_str
        body:       null
        id:         msg_id++
        user_id:    null
        type:       'TimestampMessage'
        starred:    false
      ) + '\r'
      console.info "[room #{room_id}] sent message #{msg_id-1} timestamp #{fmnow_str}"

    now_str = cfDate now
    buffer += JSON.stringify(
      room_id:    room_id
      created_at: now_str
      body:       "User #{user_id} says something like føø at #{now}"
      id:         msg_id++
      user_id:    user_id
      type:       'TextMessage' # TODO: add more types
      starred:    Math.random() > 0.99
    ) + '\r'
    console.info "[room #{room_id}] sent message #{msg_id-1} from user #{user_id} at #{now_str}"

    last_update[room_id] = now.getTime()
    res.write buffer

    timer = setTimeout sendMessages, Math.random()*25e3+5e3

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

fake_rooms = [
  {
    topic: 'Something about Room 1'
    created_at: '1970/01/01 00:00:00 +0000'
    locked: false
    updated_at: '2013/01/01 01:23:45 +0000'
    name: 'Room #1'
    id: 1
    membership_limit: 100
  }
  {
    topic: 'Something about Room 2'
    created_at: '1980/01/01 00:00:00 +0000'
    locked: false
    updated_at: '2003/01/01 01:23:45 +0000'
    name: 'Room #2'
    id: 2
    membership_limit: 100
  }
]

app.get '/rooms', (req, res) ->
  extra_room =
    topic: 'Something about Room 3'
    created_at: '1990/01/01 00:00:00 +0000'
    locked: false
    updated_at: '1993/01/01 01:23:45 +0000'
    name: 'Room #3'
    id: 3
    membership_limit: 100
  res.send rooms: fake_rooms.concat(extra_room)

# TODO: actually let you join rooms via session or something
app.post '/room/:id/join', (req, res) -> res.send 200

app.get '/presence', (req, res) ->
  res.send rooms: fake_rooms

port = process.env.PORT ? 3000
app.listen port
console.log "Listening on port #{port}"
