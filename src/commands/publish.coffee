import Stack from "../virtual-resources/stack"
import {bellChar} from "../utils"
import compile from "../configuration"

Publish = (stopwatch, env, options) ->
  try
    appRoot = process.cwd()
    console.log "Compiling configuration for publish"
    config = await compile appRoot, env, options.profile
    stack = await Stack config

    console.log "Publishing..."
    await stack.publish options.force
    console.log "Done. (#{stopwatch()})"
  catch e
    console.error "Publish failure:"
    console.error e.stack
  console.info bellChar

export default Publish
