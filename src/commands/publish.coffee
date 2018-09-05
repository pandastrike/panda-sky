import {write} from "fairmont"
import {yaml} from "panda-serialize"
import Stack from "../virtual-resources/stack"


import {bellChar, outputDuration} from "../utils"
import configuration from "../configuration"

Publish = (START, env, options) ->
  try
    appRoot = process.cwd()
    console.log "Compiling configuration for publish"
    config = await configuration.compile(appRoot, env, options.profile)
    stack = await Stack config

    console.log "Publishing..."
    await stack.publish()
    console.log "Done. (#{outputDuration START})\n\n"
  catch e
    console.error "Publish failure:"
    console.error e.stack
  console.info bellChar

export default Publish
