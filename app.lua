local uv = require('uv')
local wrapStream = require('coro-channel').wrapStream
local split = require('coro-split')
local openpty = require('./pty')

return function (req, read, write)
  -- Process the parameters from the url pattern.
  local cols = tonumber(req.params.cols)
  local rows = tonumber(req.params.rows)
  local program = "/" .. req.params.program

  -- Create the pair of file descriptors
  local master, slave = openpty(cols, rows)

  -- Spawn the child process that inherits the slave fd as it's stdio.
  local child = uv.spawn(program, {
    stdio = {slave, slave, slave},
    detached = true
  }, function (...)
    p("child exit", ...)
  end)

  local pipe = uv.new_pipe(false)
  pipe:open(master)
  local cread, cwrite = wrapStream(pipe)

  split(function ()
    for data in read do
      if data.opcode == 2 then
        cwrite(data.payload)
      end
    end
    cwrite()
  end, function ()
    for data in cread do
      write(data)
    end
    write()
  end)
  child:close()
  pipe:close()
end
