import compile from "../configuration"

render = (env, {profile}) ->
  try
    appRoot = process.cwd()
    config = await compile appRoot, env, profile
    for key, stack of config.environment.templates.dispatch
      console.log "=".repeat 80
      console.log "templates/#{key}"
      console.log "=".repeat 80
      console.log stack
    for key, stack of config.aws.templates.mixins
      console.log "=".repeat 80
      console.log "templates/mixins/#{key}.yaml"
      console.log "=".repeat 80
      console.log stack
  catch e
    console.error e

export default render
