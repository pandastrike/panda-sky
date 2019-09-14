import {cat, merge, include, keys} from "panda-parchment"

# Update edge with the full mixin configurations and permissions. These were already expanded in the main preprocessor flow.
updateedge = (config) ->
  {mixins, edge} = config.environment

  edge.mixins ?= []
  for m in edge.mixins
    throw new Error "mixin #{m} is not defined" if m not in keys mixins

  include config.environment.edge.lambda,
    policy: cat edge.lambda.policy,
      (mixins[m].policy for m in edge.mixins)...
    variables: merge (mixins[m].variables for m in edge.mixins)...,
      edge.lambda.variables

  config

export default updateedge
