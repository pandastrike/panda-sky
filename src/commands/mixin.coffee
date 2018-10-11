import {keys} from "panda-parchment"
import {yaml} from "panda-serialize"

import {bellChar} from "../utils"
import configuration from "../configuration"

Mixins = (name, env, {profile}, argv) ->
  try
    console.log "Compiling configuration for mixin..."
    appRoot = process.cwd()
    config = await configuration.compile(appRoot, env, profile)
    {AWS} = await require("../aws")(config.aws.region)

    {mixins} = config
    fail name if name not in keys mixins
    noCLI name if !mixins[name].cli
    console.log "Accessing mixin #{name} CLI..."
    console.log "-".repeat 80
    await mixins[name].cli AWS, config, extractMixinArgs argv
  catch e
    console.error "Command failure:"
    console.error e.stack

fail = (name) ->
  console.error """
  The mixin #{name} cannot be found within your project directory.
  Install that mixin before continuing.  This process will discontinue.
  """
  console.log "Done."
  process.exit -1

noCLI = (name) ->
  console.error """
  The mixin #{name} does not appear to have a command line interface.
  Sky cannot continue.
  """
  console.log "Done."
  process.exit -1

extractMixinArgs = (argv) ->
  x = argv.shift() until x == "mixin"
  argv

export default Mixins
