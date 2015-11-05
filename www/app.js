function decodeUtf8(utf8) {
  return decodeURIComponent(window.escape(utf8));
}

function encodeUtf8(unicode) {
  return window.unescape(encodeURIComponent(unicode));
}

function fromRaw(raw, binary, offset) {
  var length = raw.length;
  if (offset === undefined) {
    offset = 0;
    if (binary === undefined) binary = new Uint8Array(length);
  }
  for (var i = 0; i < length; i++) {
    binary[offset + i] = raw.charCodeAt(i);
  }
  return binary;
}

function toRaw(binary, start, end) {
  var raw = "";
  if (end === undefined) {
    end = binary.length;
    if (start === undefined) start = 0;
  }
  for (var i = start; i < end; i++) {
    raw += String.fromCharCode(binary[i]);
  }
  return raw;
}

var cols = Math.floor((window.innerWidth - 4.8 - 4.8) / 6.6125);
var rows = Math.floor((window.innerHeight -4.8 - 4.8) / 12.8);
var program = "/bin/bash";
var url = "ws://localhost:9000/" + cols + "/" + rows + program;
var connection = new WebSocket(url, ["xterm"]);
connection.binaryType = 'arraybuffer';

connection.onopen = function () {
  var term = new Terminal({
    cols: cols,
    rows: rows,
    screenKeys: true
  });

  term.on('data', function(data) {
    try { data = encodeUtf8(data); }
    catch (e) {}
    connection.send(fromRaw(data));
  });

  term.on('title', function(title) {
    document.title = title;
  });

  term.open(document.body);

  connection.onmessage = function(evt) {
    var buffer = toRaw(new Uint8Array(evt.data));
    try { buffer = decodeUtf8(buffer); }
    catch (e) {}
    term.write(buffer);
  };

  connection.onclose = function() {
    term.destroy();
  };
};
