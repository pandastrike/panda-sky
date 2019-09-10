import {cat, merge, include, keys} from "panda-parchment"

# Update worker with the full mixin configurations and permissions. These were already expanded in the main preprocessor flow.
updateWorker = (config) ->
  {mixins, worker} = config.environment

  worker.mixins ?= []
  for m in worker.mixins
    throw new Error "mixin #{m} is not defined" if m not in keys mixins

  include config.environment.worker.lambda,
    policy: cat worker.lambda.policy,
      (mixins[m].policy for m in worker.mixins)...
    variables: merge (mixins[m].variables for m in worker.mixins)...,
      worker.lambda.variables

  config

export default updateWorker
