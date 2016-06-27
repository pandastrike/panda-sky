{define} = require "panda-9000"
{async, first, sleep} = require "fairmont"

define "publish", async (env) ->

  stack = yield require("./aws/cloudformation")(env)

  console.log "Creating API"
  id = yield stack.create()
  console.log "Waiting for deployment to be ready."
  yield stack.createWait id
  console.log "Done"



  # With the backend deployed, it's safe to deploy the frontend.
  #yield shell "../node_modules/haiku9/lib/cli.js publish #{env}"
