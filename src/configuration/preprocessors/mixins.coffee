import {resolve} from "path"
import SDK from "aws-sdk"
import {flow} from "panda-garden"
import {cat, merge} from "panda-parchment"
import {exists} from "panda-quill"

class Mixin
  @create: ({name, policy, varaibles, template, cli}) ->
    @policy ?=  []
    @variables ?= {}
    @cli ?= false

    new Mixin {name, policy, varaibles, template, cli}

  constructor: ({@name, @policy, @variables, @template, @cli}) ->

fetch = (name) ->
  path = resolve process.cwd(), "node_modules", "sky-mixin-#{name}"
  unless await exists path
    console.error """
    ERROR: Mixin not found in project directory: #{m}

    Please install the mixin with the command

        npm install sky-mixin-#{m} --save
    """
    throw new Error "mixin module not found"

  await require(path).default

# Just like the core Sky configuration, mixins accept a terse configuration that gets expanded with implicit values and inferences.
expandMixinConfigurations = (config) ->
  config.environment.mixins ?= {}
  modules = {}
  SDK.config =
    credentials: new SDK.SharedIniFileCredentials {profile: config.profile}
    region: config.region
    sslEnabled: true

  for name, mixin of config.environment.mixins
    {type, configuration} = mixin
    mixin = Mixin.create await (await fetch type) SDK, config, configuration

  config

# Update partitions with the full mixin configurations and permissions.
updatePartitions = (config) ->
  {mixins, partitions} = config.environment
  for _, partition of partitions
    partition.lambda.policy = cat partition.lambda.policy,
      (mixins[m].policy for m in partition.mixins)...
    partition.variables =
      merge (mixins[m].variables for m in partition.mixins)...,
        partition.variables

  config

Mixins = flow [
  expandMixinConfigurations
  updatePartitions
]

export default Mixins
