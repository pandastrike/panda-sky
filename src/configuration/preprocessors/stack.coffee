import {flow} from "panda-garden"

applyStackVariables = (config) ->
  config.environment.stack =
    name: "#{config.name}-#{config.env}"
    bucket: "#{config.name}-#{config.env}-#{config.projectID}"
    workers: "#{config.name}-#{config.env}-workers"

  config

Stack = flow [
  applyStackVariables
]

export default Stack
