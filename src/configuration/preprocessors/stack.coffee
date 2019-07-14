import {join} from "path"
import {flow} from "panda-garden"
import {exists} from "panda-quill"

applyStackVariables = (config) ->
  config.environment.stack =
    name: "#{config.name}-#{config.env}"
    bucket: "#{config.name}-#{config.env}-#{config.projectID}"

  config

checkForFiles = (config) ->
  unless await exists config.environment.stack.package
    throw new Error "Unable to find deploy/package.zip"

  unless await exists config.environment.stack.api
    throw new Error "Unable to find api.yaml"

  unless await exists config.environment.stafck.sky
    throw new Error "Unable to find sky.yaml"

  config


Stack = flow [
  applyStackVariables
  checkForFiles
]

export default Stack
