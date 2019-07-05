import {spawn} from "child_process"
import {shell, empty} from "fairmont"
import compile from "../configuration"

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
    config = await compile appRoot, env, profile
    cfo = config.sundog.CloudFormation()

    # Get URL for the API endpoint of an arbitrary Sky stack.
    getEndpoint = (name, env) ->
      try
        id = await cfo.output "API", name
        "https://#{id}.execute-api.#{config.aws.region}.amazonaws.com/#{env}"
      catch
        false # Stack does not exist or have an API endpoint.

    url = await getEndpoint config.aws.stack.name, config.env
    if !url
      console.warn "There is no API endpoint available for this environment."
      console.log "Done."
      process.exit()
    else
      console.log "-".repeat 40
      console.log "Issuing npm test command."
      console.log "-".repeat 40
      argv = trimARGV env, argv
      argv.unshift "test", url
      test = spawn "npm", argv
      test.stdout.on "data", (data) -> console.info data.toString()
      test.stderr.on "data", (data) -> console.info data.toString()
      test.on "close", (exitCode) ->
        console.log "-".repeat 40
        console.log "Done."
        process.exit exitCode
  catch e
    console.error e.stack

export default Test
