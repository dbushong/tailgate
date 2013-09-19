{Campfire} = require 'campfire'
{inspect}  = require 'util'

campfire = new Campfire
  token: '123'
  account: 'some_account'
  api_host: 'localhost'
  api_port: 3000
  streaming_host: 'localhost'
  streaming_port: 3000

campfire.join 1, (err, room) ->
  room.listen (msg) ->
    console.log inspect msg
