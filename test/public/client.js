// Generated by CoffeeScript 1.6.3
(function() {
  var log, log_elem,
    __slice = [].slice;

  log_elem = document.getElementById('log');

  log = function() {
    var li, msg;
    msg = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    li = document.createElement('li');
    li.appendChild(document.createTextNode(msg));
    return log_elem.appendChild(li);
  };

  this.xhr = new XMLHttpRequest;

  xhr.open('get', 'http://localhost:3000/room/1/live.json');

  xhr.onreadystatechange = function() {
    return console.log('onreadystatechange', xhr.readyState, xhr.status, xhr.responseText);
  };

  xhr.send(null);

}).call(this);

/*
//@ sourceMappingURL=client.map
*/
