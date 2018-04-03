{async, empty} = require "fairmont"
configuration = require "../configuration"
require "colors"

module.exports = async ({profile}) ->
  try
    appRoot = process.cwd()
    console.error "Preparing task."
    config = yield configuration.compile(appRoot, false, profile)
    sky = yield require("../aws/sky")(false, config)

    deployments = yield sky.cfo.list config.name
    if empty deployments
      console.error "No active deployments detected."
    else
      console.error "=".repeat 80
      for {env, url, status} in deployments
        msg = "#{env} (#{status})"
        if /COMPLETE/.test status
          console.error msg.green
          console.error "      #{url}"
        else if /IN_PROGRESS/.test status
          console.error msg.yellow
          console.error "      #{url}"
        else
          console.error msg.red
          console.error "      #{url}"
      console.error "=".repeat 80
  catch e
    console.error "List Failure:"
    console.error e.stack
