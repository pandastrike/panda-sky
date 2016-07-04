{define} = require "panda-9000"
{async, first, sleep} = require "fairmont"

define "publish", async (env) ->
  config = yield require("./configuration/compile")(env)
  stack = yield require("./aws/cloudformation")(env, config)

  console.log "Creating API"
  id = yield stack.create()
  console.log "Waiting for deployment to be ready."
  yield stack.createWait id
  console.log "Done"
