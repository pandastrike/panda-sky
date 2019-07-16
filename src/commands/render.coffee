import compile from "../configuration"

render = (env, {profile}) ->
  try
    appRoot = process.cwd()
    config = await compile appRoot, env, profile

    console.log "=".repeat 80
    console.log "dispatch/index.yaml"
    console.log "=".repeat 80
    console.log config.environment.templates.dispatch

    for key, stack of config.environment.templates.partitions
      console.log "=".repeat 80
      console.log "partitions/#{key}/index.yaml"
      console.log "=".repeat 80
      console.log stack

    for key, stack of config.environment.templates.mixins
      console.log "=".repeat 80
      console.log "mixins/#{key}/index.yaml"
      console.log "=".repeat 80
      console.log stack

  catch e
    console.error e

export default render
