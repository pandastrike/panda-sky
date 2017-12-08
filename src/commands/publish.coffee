{async, write} = require "fairmont"
{yaml} = require "panda-serialize"


{bellChar, outputDuration} = require "../utils"
configuration = require "../configuration"

module.exports = async (START, env, options) ->
  try
    appRoot = process.cwd()
    console.error "Compiling configuration for publish"
    config = yield configuration.compile(appRoot, env)
    sky = yield require("../aws/sky")(env, config)

    console.error "Publishing..."
    isPublishing = yield sky.stack.publish()
    yield sky.cfo.publishWait() if isPublishing
    yield sky.stack.postPublish()
    yield writeOutput sky if options.output
    console.error "Done. (#{outputDuration START})\n\n"
  catch e
    console.error "Publish failure:"
    console.error e.stack
  console.error bellChar
  sky.cfo

# The developer may use the --output flag to write the API configuration to a
# file, including the endpoint.
writeOutput = async (sky) ->
  config = url: yield sky.cfo.getApiUrl()
  yield write options.output, (yaml config)
