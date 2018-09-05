import {define, run} from "panda-9000"
import {first, sleep} from "fairmont"

import {bellChar, outputDuration} from "../utils"
import configuration from "../configuration"
import Stack from "../virtual-resources/stack"

START = 0
Delete = (start, env, {profile}) ->
  START = start
  run "delete", [env, profile]

define "delete", (env, profile) ->
  try
    appRoot = process.cwd()
    config = await configuration.compile(appRoot, env, profile)
    stack = await Stack config

    console.log "Deleting Sky deployment..."
    await stack.delete()
    console.log "Done. (#{outputDuration START})\n\n"
  catch e
    console.error e.stack
  console.info bellChar

export default Delete
