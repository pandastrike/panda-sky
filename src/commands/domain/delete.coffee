import {bellChar, outputDuration} from "../../utils"
import compile from "../../configuration"
import {teardownDomain} from "../../virtual-resources/domain"

module.exports = (stopwatch, env, options) ->
  try
    appRoot = process.cwd()
    console.log "Compiling configuration for API custom domain."
    config = await compile appRoot, env, options.profile

    await teardownDomain config
    console.log "Done. (#{stopwatch()})"
  catch e
    console.error "Delete failure:"
    console.error e.stack
  console.info bellChar
