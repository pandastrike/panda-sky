{define} = require "panda-9000"
{async, first, sleep} = require "fairmont"

{bellChar} = require "../utils"
configuration = require "../configuration"

define "publish", async (env) ->
  try
    appRoot = process.cwd()
    config = yield configuration.compile(appRoot, env)
    stack = yield require("../aws/cloudformation")(env, config)

    id = yield stack.publish()
    if id
      console.log "Waiting for deployment to be ready."
      yield stack.publishWait id
    yield stack.postPublish()
    console.log "Done"
  catch e
    console.error e.stack
  console.log bellChar
