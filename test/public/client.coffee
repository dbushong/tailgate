log_elem = document.getElementById 'log'

log = (msg...) ->
  li = document.createElement 'li'
  li.appendChild document.createTextNode msg
  log_elem.appendChild li

@xhr = new XMLHttpRequest

xhr.open 'get', 'http://localhost:3000/room/1/live.json'
xhr.onreadystatechange = ->
  console.log 'onreadystatechange', xhr.readyState, xhr.status, xhr.responseText
xhr.send null
