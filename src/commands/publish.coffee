import {yaml} from "panda-serialize"
import Stack from "../virtual-resources/stack"


import {bellChar} from "../utils"
import configuration from "../configuration"

Publish = (stopwatch, env, options) ->
  try
    appRoot = process.cwd()
    console.log "Compiling configuration for publish"
    config = await configuration.compile(appRoot, env, options.profile)
    stack = await Stack config

    console.log "Publishing..."
    await stack.publish()
    console.log "Done. (#{stopwatch()})"
  catch e
    console.error "Publish failure:"
    console.error e.stack
  console.info bellChar

export default Publish
