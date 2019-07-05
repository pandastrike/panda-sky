# This checks that the developer's selected environment is valid and sets some smart defaults for the Lambda resources.
import SDK from "aws-sdk"
import Sundog from "sundog"
import {keys} from "panda-parchment"

check = (config) ->
  {name, env, profile} = config

  if config.environments[env]
    config.environment = config.environments[env]
  else
    console.error """
      The environment "#{env}" is not present in your sky.yaml configuration.
      Available environments are:
      #{(keys config.environments).join ", "}
    """
    throw new Error "environment \"#{env}\" is not specified"

  # Sundog instanication
  SDK.config =
     credentials: new SDK.SharedIniFileCredentials {profile}
     region: config.region
     sslEnabled: true
  config.sundog = Sundog(SDK).AWS

  # Top level IDs.
  config.accountID = (await config.sundog.STS().whoAmI()).Account

  config

export default check
