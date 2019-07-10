# Set the environment variables that are injected into each Lambda and tags for AWS resources.  The developer may add or overwrite default values.
import {join} from "path"
import {merge} from "panda-parchment"
import {flow} from "panda-garden"

applyStackVariables = (config) ->
  config.environment.stack =
    name: "#{config.name}-#{config.env}"
    bucket: "#{config.name}-#{config.env}-#{config.projectID}"
    package: join process.cwd(), "deploy", "package.zip"
    api: join process.cwd(), "api.yaml"
    sky: join process.cwd(), "sky.yaml"
  config

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
  applyStackVariables config
  applyEnvironmentVariables
  applyTags
]

export default Variables
