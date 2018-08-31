import {define, run} from "panda-9000"
import {first, sleep} from "fairmont"

import {bellChar, outputDuration} from "../utils"
import configuration from "../configuration"

START = 0
Delete = (start, env, {profile}) ->
  START = start
  run "delete", [env, profile]

define "delete", (env, profile) ->
  try
    appRoot = process.cwd()
    config = await configuration.compile(appRoot, env, profile)
    sky = await require("../aws/sky")(env, config)

    console.log "Deleting Sky deployment..."
    isDeleting = await sky.stack.delete()
    if isDeleting
      console.log "-- Waiting for stack deletion to complete."
      await sky.cfo.deleteWait()
    else
      console.error "WARNING: No Sky stack detected. Now checking for metadata."

    await sky.stack.postDelete()
    console.log "Done. (#{outputDuration START})\n\n"
  catch e
    console.error e.stack
  console.info bellChar

export default Delete
