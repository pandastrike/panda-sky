import {bellChar, outputDuration} from "../../utils"
import configuration from "../../configuration"
import Domain from "../../virtual-resources/domain"

module.exports = (stopwatch, env, options) ->
  try
    appRoot = process.cwd()
    console.log "Compiling configuration for API custom domain."
    config = await configuration.compile appRoot, env, options.profile
    domain = await Domain config

    await domain.publish()
    console.log "Done. (#{stopwatch()})"
  catch e
    console.error "Publish failure:"
    console.error e.stack
  console.info bellChar
