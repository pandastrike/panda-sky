import compile from "../configuration"

banner = (str, stack) ->
  console.log "=".repeat 80
  console.log str
  console.log "=".repeat 80
  console.log stack

render = (env, {profile}) ->
  try
    appRoot = process.cwd()
    config = await compile appRoot, env, profile

    banner "dispatch/index.yaml", config.environment.templates.dispatch

    for key, stack of config.environment.templates.mixins
      banner "mixins/#{key}/index.yaml", stack

  catch e
    console.error e

export default render
