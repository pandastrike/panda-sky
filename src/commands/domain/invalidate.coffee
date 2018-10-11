import {bellChar, outputDuration} from "../../utils"
import configuration from "../../configuration"
import Domain from "../../virtual-resources/domain"

module.exports = (stopwatch, env, options) ->
  console.warn "This feature is not yet implemented."
  # try
  #   appRoot = process.cwd()
  #   console.error "Compiling configuration for API custom domain."
  #   config = await configuration.compile appRoot, env, options.profile
  #   domain = await Domain config
  #
  #   await sky.domain.invalidate()
  #   console.error "Done. (#{outputDuration START})\n\n"
  # catch e
  #   console.error "Invalidation failure:"
  #   console.error e.stack
  # console.info bellChar
  # sky.cfo
