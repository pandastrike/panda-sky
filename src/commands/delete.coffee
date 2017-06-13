{define} = require "panda-9000"
{async, first, sleep} = require "fairmont"

{bellChar} = require "../utils"
configuration = require "../configuration"

define "delete", async (env) ->
  try
    appRoot = "api"
    config = yield configuration.compile(appRoot, env)
    stack = yield require("../aws/cloudformation")(appRoot, env, config)

    console.error "Deleting API"
    id = yield stack.delete()
    console.error "Waiting to Confirm Deletion"
    yield stack.deleteWait id
    yield stack.postDelete()
    console.error "Done"
  catch e
    console.error e.stack
  console.error bellChar
