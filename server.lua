require('weblit-websocket')
require('weblit-app')

.bind({
  host = "127.0.0.1", -- Change to "0.0.0.0" if you want the world to have access (BEWARE)
  port = 9000
})

.use(require('weblit-logger'))
.use(require('weblit-auto-headers'))
.use(require('weblit-etag-cache'))

.use(require('weblit-static')(module.dir .. "/www"))

.websocket({
  path = "/:cols/:rows/:program:",
  protocol = "xterm"
}, require('./app'))

.start()
