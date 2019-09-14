import {flow} from "panda-garden"
import {merge} from "panda-parchment"

applyTags = (config) ->
  values =
    project: config.name
    environment: config.env
    type: config.environment.edge.type

  # Apply explicit tags, deleteing defaults if there is an override.
  values = merge values, config.environment.edge.tags

  # Format as "Key" and "Value" for CloudFormation
  config.environment.edge.tags = ({Key, Value} for Key, Value of values)

  config

Variables = flow [
  applyTags
]

export default Variables
