import {empty} from "fairmont"
import configuration from "../configuration"
import "colors"

List = ({profile}) ->
  try
    appRoot = process.cwd()
    console.log "Preparing task."
    config = await configuration.compile(appRoot, false, profile)
    sky = await require("../aws/sky")(false, config)

    deployments = await sky.cfo.list config.name
    if empty deployments
      console.warn "No active deployments detected."
    else
      console.log "=".repeat 80
      for {env, url, status} in deployments
        msg = "#{env} (#{status})"
        if /COMPLETE/.test status
          console.log msg.green
          console.log "      #{url}"
        else if /IN_PROGRESS/.test status
          console.log msg.yellow
          console.log "      #{url}"
        else
          console.log msg.red
          console.log "      #{url}"
      console.log "=".repeat 80
  catch e
    console.error "List Failure:"
    console.error e.stack

export default List
