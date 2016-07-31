{define} = require "panda-9000"
{async, first, sleep} = require "fairmont"

define "delete", async (env) ->
  try
    config = yield require("./configuration/compile")(env)
    stack = yield require("./aws/cloudformation")(env, config)

    console.log "Deleting API"
    id = yield stack.delete()
    console.log "Waiting to Confirm Deletion"
    yield stack.deleteWait id
    yield stack.postDelete()
    console.log "Done"
    console.log '\u0007'
  catch e
    console.log e.stack
