import {flow} from "panda-garden"
import {merge} from "panda-parchment"

applyTags = (config) ->
  values =
    project: config.name
    environment: config.env
    worker: config.environment.worker.name

  # Apply explicit tags, deleteing defaults if there is an override.
  values = merge values, config.environment.worker.tags

  # Format as "Key" and "Value" for CloudFormation
  config.environment.worker.tags = ({Key, Value} for Key, Value of values)

  config

Variables = flow [
  applyTags
]

export default Variables
