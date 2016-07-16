{define} = require "panda-9000"
{async, first, sleep} = require "fairmont"

define "publish", async (env) ->
  try
    config = yield require("./configuration/compile")(env)
    stack = yield require("./aws/cloudformation")(env, config)

    id = yield stack.publish()
    if id
      console.log "Waiting for deployment to be ready."
      yield stack.publishWait id
    yield stack.postPublish()
    console.log "Done"
  catch error
    console.error error.stack
