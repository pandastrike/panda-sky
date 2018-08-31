import {shell, empty} from "fairmont"
import configuration from "../configuration"
import {spawn} from "child_process"

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

Test = (env, {profile}, argv) ->
  try
    appRoot = process.cwd()
    console.log "Preparing task."
    config = await configuration.compile(appRoot, env, profile)
    sky = await require("../aws/sky")(env, config)

    url = await sky.cfo.lookupEndpoint config.stackName, env
    if !url
      console.error "There is no API endpoint available for this environment."
      console.log "Done."
      process.exit()
    else
      console.log "-".repeat 80
      console.log "Issuing npm test command."
      console.log "-".repeat 80
      argv = trimARGV env, argv
      argv.unshift "test", url
      test = spawn "npm", argv
      test.stdout.on "data", (data) -> console.log data.toString()
      test.stderr.on "data", (data) -> console.log data.toString()
      test.on "close", (exitCode) ->
        console.log "-".repeat 80
        console.log "Done."
        process.exit exitCode
  catch e
    console.error e.stack

export default Test
