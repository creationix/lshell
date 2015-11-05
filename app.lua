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
local util = ffi.load("util")

return function (req, read, write)

  local master = ffi.new("int[1]")
  local slave = ffi.new("int[1]")
  local winp = ffi.new("struct winsize")
  winp.ws_row = tonumber(req.params.rows)
  winp.ws_col = tonumber(req.params.cols)
  util.openpty(master, slave, nil, nil, winp)
  master, slave = master[0], slave[0]
  local program = "/" .. req.params.program
  local child
  child = uv.spawn(program, {
    stdio = {slave, slave, slave},
    detached = true
  }, function (...)
    p("exit", child, ...)
  end)

  local pipe = uv.new_pipe(false)
  pipe:open(master)

  local cread, cwrite = wrapStream(pipe)

  split(function ()
    for data in read do
      if data.opcode == 2 then
        cwrite(data.payload)
      elseif data.opcode == 8 then
        break
      end
    end
    child:close()
    cwrite()
  end, function ()
    for data in cread do
      write(data)
    end
    write()
  end)
end
