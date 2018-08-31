import {write} from "fairmont"
import {yaml} from "panda-serialize"


import {bellChar, outputDuration} from "../utils"
import configuration from "../configuration"

Publish = (START, env, options) ->
  try
    appRoot = process.cwd()
    console.log "Compiling configuration for publish"
    config = await configuration.compile(appRoot, env, options.profile)
    sky = await require("../aws/sky")(env, config)

    console.log "Publishing..."
    isPublishing = await sky.stack.publish()
    await sky.cfo.publishWait() if isPublishing
    await sky.stack.postPublish()
    await writeOutput sky if options.output
    console.log "Done. (#{outputDuration START})\n\n"
  catch e
    console.error "Publish failure:"
    console.error e.stack
  console.info bellChar
  sky.cfo

# The developer may use the --output flag to write the API configuration to a
# file, including the endpoint.
writeOutput = (sky) ->
  config = url: await sky.cfo.getApiUrl()
  await write options.output, (yaml config)

export default Publish
