{async, shell, empty} = require "fairmont"
configuration = require "../configuration"
{spawn} = require "child_process"

# Remove arguments from the CLI input and only enter those beyond the environment name into npm test command.
trimARGV = (env, argv) ->
  while true
    if empty argv
      return argv
    else if argv[0] == env
      argv.shift()
      return argv
    else
      argv.shift()

module.exports = async (env, {profile}, argv) ->
  try
    appRoot = process.cwd()
    console.error "Preparing task."
    config = yield configuration.compile(appRoot, env, profile)
    sky = yield require("../aws/sky")(env, config)

    url = yield sky.cfo.lookupEndpoint config.stackName, env
    if !url
      console.error "There is no API endpoint available for this environment."
      console.error "Done."
      process.exit()
    else
      console.error "-".repeat 80
      console.error "Issuing npm test command."
      console.error "-".repeat 80
      argv = trimARGV env, argv
      argv.unshift "test", url
      test = spawn "npm", argv
      test.stdout.on "data", (data) -> console.error data.toString()
      test.stderr.on "data", (data) -> console.error data.toString()
      test.on "close", (exitCode) ->
        console.error "-".repeat 80
        console.error "Done."
        process.exit exitCode
  catch e
    console.error e.stack
