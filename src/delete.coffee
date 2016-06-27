{define} = require "panda-9000"
{async, first, sleep} = require "fairmont"

define "delete", async (env) ->
  stack = yield require("./aws/cloudformation")(env)

  console.log "Deleting API"
  id = yield stack.delete()
  console.log "Waiting to Confirm Deletion"
  yield stack.deleteWait id
  console.log "Done"













  # With the backend deployed, it's safe to deploy the frontend.
  #yield shell "../node_modules/haiku9/lib/cli.js publish #{env}"
