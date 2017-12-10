{resolve} = require "path"
{async, keys, exists, cat} = require "fairmont"
allowedMixins = ["s3"] # "dynamodb", "sqs", "elastic", "cognito"]

mixinInvalid = (env, m) ->
  console.error """
  ERROR: Invalid mixin:
    Environment: #{env}
    Mixin: #{m}

  Please correct your sky.yaml configuration before continuing.
  This process will now discontinue.
  Done.
  """
  process.exit -1

mixinUnavailable = (m) ->
  console.error """
  ERROR: Mixin not found in project directory: #{m}

  Please install the mixin with the command

      npm install sky-mixin-#{m} --save

  This process will now discontinue.
  Done.
  """
  process.exit -1


# Check to make sure the listed mixins are valid.
fetchMixinNames = (globals) ->
  {env} = globals
  {mixins} = globals.aws.environments[env]
  return false if !mixins
  mixins = keys mixins

  mixinInvalid env, m for m in mixins when m not in allowedMixins
  mixins

# Collect all the mixin packages.
fetchMixinPackages = async (mixins) ->
  packages = {}
  for m in mixins
    path = resolve process.cwd(), "node_modules", "sky-mixin-#{m}"
    mixinUnavailable m if !yield exists path
    packages[m] = require(path).default
  packages

# Gather together all the project's mixin code into one dictionary.
fetchMixins = async (globals) ->
  mixins = fetchMixinNames globals
  return if !mixins
  yield fetchMixinPackages mixins

# Before we can render either the mixins or the Core Sky API, we need to
# accomdate the changes caused by the mixins.
reconcileConfigs = (mixins, globals) ->
  console.log global.policyStatements
  # Access the policyStatement hook each mixin, and add to the array we haveThe
  s = globals.policyStatements
  s = cat s, v.policyStatements for k, v of mixins when v.policyStatements

  globals.policyStatements = s
  globals

# Pull the template and schema from the mixin code.  Validate the configuration
renderMixins = async (appRoot, globals) ->
  a = yield 1

module.exports = {fetchMixins, renderMixins, reconcileConfigs}
