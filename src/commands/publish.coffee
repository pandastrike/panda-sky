import {bellChar} from "../utils"
import compile from "../configuration"
import {publishStack} from "../virtual-resources"

Publish = (stopwatch, env, options) ->
  try
    appRoot = process.cwd()
    console.log "Compiling configuration for publish"
    config = await compile appRoot, env, options.profile

    console.log "Publishing..."
    await publishStack config
    console.log "Done. (#{stopwatch()})"
  catch e
    console.error "Publish failure:"
    console.error e.stack
  console.info bellChar

export default Publish
