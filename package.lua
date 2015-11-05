return {
  name = "creationix/lshell",
  version = "0.0.1",
  description = "A remote shell using luvit, websockets, and term.js",
  tags = { "pty", "websocket", "terminal" },
  license = "MIT",
  author = { name = "Tim Caswell", email = "tim@creationix.com" },
  homepage = "https://github.com/creationix/lshell",
  dependencies = {
    'creationix/weblit-websocket',
    'creationix/weblit-app',
    'creationix/coro-channel',
    'creationix/coro-split',
    'creationix/weblit-logger',
    'creationix/weblit-auto-headers',
    'creationix/weblit-etag-cache',
    'creationix/weblit-static',
  },
  files = {
    "**.lua",
    "!test*"
  }
}
