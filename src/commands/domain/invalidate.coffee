import {bellChar, outputDuration} from "../../utils"
import compile from "../../configuration"
import {invalidateDomain} from "../../virtual-resources"

module.exports = (stopwatch, env, options) ->
  try
    appRoot = process.cwd()
    console.log "Compiling configuration for API custom domain."
    config = await compile appRoot, env, options.profile

    await publishDomain config
    console.log "Done. (#{stopwatch()})"
  catch e
    console.error "Invalidation failure:"
    console.error e.stack
  console.info bellChar
