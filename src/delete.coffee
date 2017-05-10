{define} = require "panda-9000"
{async, first, sleep} = require "fairmont"

{bellChar} = require "./utils"
configuration = require "./configuration"

define "delete", async (env) ->
  try
    appRoot = process.cwd()
    config = yield configuration.compile(appRoot, env)
    stack = yield require("./aws/cloudformation")(env, config)

    console.log "Deleting API"
    id = yield stack.delete()
    console.log "Waiting to Confirm Deletion"
    yield stack.deleteWait id
    yield stack.postDelete()
    console.log "Done"
  catch e
    console.log e.stack
  console.log bellChar
