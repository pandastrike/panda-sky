{async, keys} = require "fairmont"
{yaml} = require "panda-serialize"

{bellChar} = require "../utils"
configuration = require "../configuration"

module.exports = async (name, env, argv) ->
  try
    console.error "Compiling configuration for mixin..."
    appRoot = process.cwd()
    config = yield configuration.compile(appRoot, env)

    {mixins} = config
    fail name if name not in keys mixins
    noCLI name if !mixins[name].cli
    console.error "Accessing mixin #{name} CLI..."
    console.error "-".repeat 80
    yield mixins[name].cli config, extractMixinArgs argv
  catch e
    console.error "Command failure:"
    console.error e.stack

fail = (name) ->
  console.error """
  The mixin #{name} cannot be found within your project directory.
  Install that mixin before continuing.  This process will discontinue.

  Done.
  """
  process.exit -1

noCLI = (name) ->
  console.error """
  The mixin #{name} does not appear to have a command line interface.
  Sky cannot continue.

  Done.
  """
  process.exit -1

extractMixinArgs = (argv) ->
  x = argv.shift() until x == "mixin"
  argv
