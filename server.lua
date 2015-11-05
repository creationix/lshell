local ffi = require('ffi')
local uv = require('uv')
local wrapStream = require('coro-channel').wrapStream
local split = require('coro-split')

ffi.cdef[[
  struct winsize {
      unsigned short ws_row;
      unsigned short ws_col;
      unsigned short ws_xpixel;   /* unused */
      unsigned short ws_ypixel;   /* unused */
  };
  int openpty(int *amaster, int *aslave, char *name,
              void *termp,
              const struct winsize *winp);
]]
local util = ffi.open("util")

require('weblit-websocket')
require('weblit-app')

.bind({
  host = "127.0.0.1",
  port = 9000
})

.use(require('weblit-logger'))
.use(require('weblit-auto-headers'))
.use(require('weblit-etag-cache'))

.use(require('weblit-static')(module.dir .. "/www"))

.websocket({
  path = "/:cols/:rows/:program:",
  protocol = "xterm"
}, function (req, read, write)

  local master = ffi.new("int[1]")
  local slave = ffi.new("int[1]")
  local winp = ffi.new("struct winsize")
  winp.ws_row = tonumber(req.params.rows)
  winp.ws_col = tonumber(req.params.cols)
  util.openpty(master, slave, nil, nil, winp)
  master, slave = master[0], slave[0]
  local program = "/" .. req.params.program
  uv.spawn(program, {
    stdio = {slave, slave, slave},
    detached = true
  }, function () end)

  local pipe = uv.new_pipe(false)
  pipe:open(master)

  local cread, cwrite = wrapStream(pipe)

  split(function ()
    for data in read do
      cwrite(data.payload)
    end
    cwrite()
  end, function ()
    for data in cread do
      write(data)
    end
    write()
  end)
end)

.start()
