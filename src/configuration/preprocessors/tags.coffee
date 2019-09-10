import {flow} from "panda-garden"
import {merge} from "panda-parchment"

applyTags = (config) ->
  values =
    project: config.name
    environment: config.env

  # Apply explicit tags, deleteing defaults if there is an override.
  values = merge values, config.tags
  config.environment.dispatch.tags =
    merge values, config.environment.dispatch.tags

  # Format as "Key" and "Value" for CloudFormation
  config.tags = ({Key, Value} for Key, Value of values)
  config.environment.dispatch.tags =
    ({Key, Value} for Key, Value of config.environment.dispatch.tags)

  config

Variables = flow [
  applyTags
]

export default Variables
