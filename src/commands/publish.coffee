{define} = require "panda-9000"
{async, first, sleep} = require "fairmont"

{bellChar} = require "../utils"
configuration = require "../configuration"

define "publish", async (env) ->
  try
    appRoot = process.cwd()
    console.error "compiling configuration"
    config = yield configuration.compile(appRoot, env)
    console.error "generating 'stack'"
    stack = yield require("../aws/cloudformation")(env, config)

    console.error "stack.publish()"
    id = yield stack.publish()
    if id
      console.error "Waiting for deployment to be ready."
      yield stack.publishWait id
    yield stack.postPublish()
    console.error "Done"
  catch e
    console.error e.stack
  console.error bellChar
