# This checks that the developer's selected environment is valid and sets some smart defaults for the Lambda resources.
import SDK from "aws-sdk"
import Sundog from "sundog"

check = (config) ->
  {name, env, profile, aws} = config
  if !aws.environments?[env]
    console.error "The specified environment #{env} is not specified within sky.yaml"
    process.exit -1

  config.environment = config.environments[env]

  # Sundog instanication
  SDK.config =
     credentials: new SDK.SharedIniFileCredentials {profile}
     region: config.aws.region
     sslEnabled: true
  config.sundog = Sundog(SDK).AWS

  # Top level IDs.
  config.accountID = (await config.sundog.STS().whoAmI()).Account

  config

export default check
