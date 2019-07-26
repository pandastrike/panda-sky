import {resolve} from "path"
import SDK from "aws-sdk"
import {flow} from "panda-garden"
import {cat, merge, dashed, include, keys} from "panda-parchment"
import {exists} from "panda-quill"
import {yaml} from "panda-serialize"

fetch = (name) ->
  path = resolve process.cwd(), "node_modules", "sky-mixin-#{name}"
  unless await exists path
    console.error """
    ERROR: Mixin not found in project directory: #{name}

    Please install the mixin with the command

        npm install sky-mixin-#{name} --save
    """
    throw new Error "mixin module not found"

  await require(path).default

# Just like the core Sky configuration, mixins accept a terse configuration that gets expanded with implicit values and inferences.
expandMixinConfigurations = (config) ->
  class Mixin
    @create: ({name, policy, varaibles, vpc, template, cli, beforeHook}) ->
      @policy ?=  []
      @variables ?= {}
      @cli ?= false
      @vpc ?= false
      beforeHook ?= false

      stack = dashed "#{config.name} #{config.env} mixin #{name}"

      new Mixin {name, policy, vpc, varaibles, template, cli, beforeHook, stack}

    constructor: ({@name, @policy, @variables,
      @vpc, @template, @cli, @beforeHook, @stack}) ->

  config.environment.mixins ?= {}
  modules = {}
  SDK.config =
    credentials: new SDK.SharedIniFileCredentials {profile: config.profile}
    region: config.region
    sslEnabled: true

  for name, mixin of config.environment.mixins
    {type, vpc, configuration} = mixin
    config.environment.mixins[name] =
      Mixin.create await (await fetch type) SDK, config, {vpc, name},
        configuration

  config

# Update partitions with the full mixin configurations and permissions.
updatePartitions = (config) ->
  {mixins, partitions} = config.environment
  for name, partition of partitions
    partition.mixins ?= []
    for m in partition.mixins
      throw new Error "mixin #{m} is not defined" if m not in keys mixins

    include config.environment.partitions[name],
      policy: cat partition.lambda.policy,
        (mixins[m].policy for m in partition.mixins)...
      variables: merge (mixins[m].variables for m in partition.mixins)...,
        partition.variables

  config

Mixins = flow [
  expandMixinConfigurations
  updatePartitions
]

export default Mixins
