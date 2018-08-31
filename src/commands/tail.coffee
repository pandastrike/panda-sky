import {write} from "fairmont"

import {bellChar, outputDuration} from "../utils"
import configuration from "../configuration"

Tail = (env, {verbose, profile}) ->
  try
    appRoot = process.cwd()
    console.log "Preparing task."
    config = await configuration.compile(appRoot, env, profile)
    sky = await require("../aws/sky")(env, config)

    console.log "Tailing Sky API logs... (Press ^C at any time to quit.)"
    console.log "=".repeat 80
    await sky.lambdas.tail(verbose)
  catch e
    console.error "Log tailing failure:"
    console.error e.stack

export default Tail
