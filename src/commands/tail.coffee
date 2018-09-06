import {bellChar, outputDuration} from "../utils"
import configuration from "../configuration"
import Handlers from "../virtual-resources/handlers"

Tail = (env, {verbose, profile}) ->
  try
    appRoot = process.cwd()
    console.log "Preparing task."
    config = await configuration.compile(appRoot, env, profile)
    handlers = await Handlers config

    console.log "Tailing Sky API logs... (Press ^C at any time to quit.)"
    console.log "=".repeat 80
    await handlers.tail verbose
  catch e
    console.error "Log tailing failure:"
    console.error e.stack

export default Tail
