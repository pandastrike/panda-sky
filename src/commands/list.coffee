import {empty, collect, select} from "fairmont"
import configuration from "../configuration"

List = ({profile}) ->
  try
    appRoot = process.cwd()
    console.log "Preparing task."
    config = await configuration.compile(appRoot, false, profile)
    cfo = config.sundog.CloudFormation

    # Get all stacks with the project name in their prefix.
    search = (projectName) ->
      query = ({StackName}) -> ///^#{projectName}-(\w+)$///.test StackName
      parseEnv = (StackName) ->
        match = ///^#{projectName}-(\w+)$///.exec StackName
        match[1]

      # Get URL for the API endpoint of an arbitrary Sky stack.
      getEndpoint = (name, env) ->
        try
          id = await cfo.output "API", name
          "https://#{id}.execute-api.#{config.aws.region}.amazonaws.com/#{env}"
        catch
          false # Stack does not exist or have an API endpoint.

      stacks = collect select query, await cfo.list()
      for {StackName, StackStatus} in stacks
        env = parseEnv StackName
        url = await getEndpoint StackName, env
        {env, url, status:StackStatus}


    deployments = await search config.name
    if empty deployments
      console.warn "No active deployments detected."
    else
      console.info "=".repeat 80
      for {env, url, status} in deployments
        msg = "#{env} (#{status})"
        if /COMPLETE/.test status
          console.info msg.green
          console.info "      #{url}"
        else if /IN_PROGRESS/.test status
          console.info msg.yellow
          console.info "      #{url}"
        else
          console.info msg.red
          console.info "      #{url}"
      console.info "=".repeat 80
  catch e
    console.error "List Failure:"
    console.error e.stack

export default List
