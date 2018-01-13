{async, write} = require "fairmont"

{bellChar, outputDuration} = require "../utils"
configuration = require "../configuration"

module.exports = async (env) ->
  try
    appRoot = process.cwd()
    console.error "Preparing task."
    config = yield configuration.compile(appRoot, env)
    sky = yield require("../aws/sky")(env, config)

    console.error "Tailing Sky API logs... (Press ^C at any time to quit.)"
    console.error "=".repeat 80
    yield sky.lambdas.tail()
  catch e
    console.error "Log tailing failure:"
    console.error e.stack
