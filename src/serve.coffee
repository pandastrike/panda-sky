http = require "http"
{define} = require "panda-9000"

define "serve", ->
  port = 8080

  http.
  createServer()
  .listen port,
  -> console.log "Mango HTTP server listening on port #{port}."
