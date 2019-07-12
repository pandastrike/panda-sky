import {flow} from "panda-garden"
import {merge} from "panda-parchment"

applyEnvironmentVariables = (config) ->
  for _, partition of config.environment.partitions
    partition.variables = merge
      environment: config.env
      skyBucket: config.environment.stack.bucket,
      config.environment.variables,
      partition.variables

  config

applyTags = (config) ->
  values =
    project: config.name
    environment: config.env

  # Apply explicit tags, deleteing defaults if there is an override.
  values = merge values, config.tags
  for name, partition of config.environment.partitions
    partition.tags = merge values, partition: name, partition.tags

  # Format as "Key" and "Value" for CloudFormation
  config.tags = ({Key, Value} for Key, Value of values)
  for _, partition of config.environment.partitions
    partition.tags = ({Key, Value} for Key, Value of partition.tags)

  config

Variables = flow [
  applyEnvironmentVariables
  applyTags
]

export default Variables
