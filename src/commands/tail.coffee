import compile from "../configuration"

Tail = (env, {verbose, profile}) ->
  throw new Error "This command is currently unavailable"
  # try
  #   appRoot = process.cwd()
  #   console.log "Preparing task."
  #   config = await compile appRoot, env, profile
  #   handlers = await Handlers config
  #
  #   console.log "Tailing Sky API logs... (Press ^C at any time to quit.)"
  #   console.log "=".repeat 80
  #   await handlers.tail verbose
  # catch e
  #   console.error "Log tailing failure:"
  #   console.error e.stack

export default Tail
