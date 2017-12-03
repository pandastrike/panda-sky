{async} = require "fairmont"

{bellChar} = require "../../utils"
configuration = require "../../configuration"

module.exports = async (env, options) ->
  try
    appRoot = process.cwd()
    console.error "Compiling configuration for API custom domain."
    config = yield configuration.compile(appRoot, env)
    sky = yield require("../../aws/sky")(env, config)

    yield sky.domain.preDelete sky.config.aws.hostnames[0], options
    console.error "\nDeleting..."
    yield sky.domain.delete sky.config.aws.hostnames[0]
    console.error "Done.\n\n"
  catch e
    console.error "Delete failure:"
    console.error e.stack
  console.error bellChar
  sky.cfo
