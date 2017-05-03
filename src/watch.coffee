{join} = require "path"
http = require "http"
{async} = require "fairmont"
{yaml} = require "panda-serialize"
{bellChar} = require "./utils"

watch = require "watch"

module.exports = async ->
  try
    # the default options
    opts =
      ignoreDotFiles: false       # When true this option means that when the file tree is walked it will ignore files that being with "."
      interval: 1                 # Specifies the interval duration in seconds, the time period between polling for file changes.
      ignoreUnreadableDir: false  # When true, this options means that when a file can't be read, this file is silently skipped.
      ignoreNotPermitted: false   # When true, this options means that when a file can't be read due to permission issues, this file is silently skipped.

    # Watch 'src/' and 'node_modules/'
    {src, node, buffer} = yield require "./watch-helpers"

    watch.createMonitor (join process.cwd(), "src"), opts, (monitor) ->
      monitor.on "created", (f, stat) -> src.created f
      monitor.on "changed", (f, curr, prev) -> src.changed f
      monitor.on "removed", (f, stat) -> src.removed f

    watch.createMonitor (join process.cwd(), "node_modules"), opts, (monitor) ->
      monitor.on "created", (f, stat) -> node.created f
      monitor.on "changed", (f, curr, prev) -> node.changed f
      monitor.on "removed", (f, stat) -> node.removed f

    console.log "Watching source code. Stop with Ctrl+C"
  catch e
    console.error e.stack
  console.log bellChar
