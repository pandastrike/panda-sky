import {resolve} from "path"
import {keys, cat, merge} from "panda-parchment"
import {exists} from "panda-quill"
import {yaml} from "panda-serialize"
import SDK from "aws-sdk"

mixinUnavailable = (m) ->
  console.error """
  ERROR: Mixin not found in project directory: #{m}

  Please install the mixin with the command

      npm install sky-mixin-#{m} --save

  This process will now discontinue.
  """
  console.log "Done."
  process.exit -1


# Check to make sure the listed mixins are valid.
fetchMixinNames = (config) ->
  {env} = config
  {mixins} = config.aws.environments[env]
  return false if !mixins
  keys mixins

# Collect all the mixin packages.
fetchMixinPackages = (mixins) ->
  packages = {}
  for m in mixins
    path = resolve process.cwd(), "node_modules", "sky-mixin-#{m}"
    mixinUnavailable m if !await exists path
    packages[m] = await require(path).default
  packages

# Gather together all the project's mixin code into one dictionary.
fetchMixins = (config) ->
  mixins = fetchMixinNames config
  return {} if !mixins
  await fetchMixinPackages mixins

# Before we can render either the mixins or the Core Sky API, we need to
# accomdate the changes caused by the mixins.
reconcileConfigs = (mixins, config) ->
  # Access the policyStatement hook each mixin, and add to the array.
  # TODO: Consider policy uniqueness constraint.
  SDK.config =
    credentials: new SDK.SharedIniFileCredentials {profile: config.profile}
    region: config.aws.region
    sslEnabled: true
  {env} = config

  s = config.policyStatements
  for name, mixin of mixins when mixin.getPolicyStatements
    _config = config.aws.environments[env].mixins[name]
    s = cat s, await mixin.getPolicyStatements _config, config, SDK
  config.policyStatements = (yaml i for i in s)

  v = config.environmentVariables
  for name, mixin of mixins when mixin.getEnvironmentVariables
    _config = config.aws.environments[env].mixins[name]
    v = merge v, await mixin.getEnvironmentVariables _config, config, SDK
  config.environmentVariables = v

  config

Mixins = (config) ->
  config.mixins = mixins = await fetchMixins config
  await reconcileConfigs mixins, config

export default Mixins
