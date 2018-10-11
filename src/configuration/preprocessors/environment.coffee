# This checks that the developer's selected environment is valid and sets some smart defaults for the Lambda resources.
import SDK from "aws-sdk"
import Sundog from "sundog"
import {keys, capitalize} from "panda-parchment"

check = (config) ->
  {name, env, profile, aws} = config
  if !aws.environments?[env]
    console.error "The specified environment #{env} is not specified within sky.yaml"
    process.exit -1

  # Lambda defaults
  config.aws.runtime = "nodejs8.10" if !aws.runtime
  config.aws.memorySize = 256 if !aws.memorySize
  config.aws.timeout = 60 if !aws.timeout

  # Sundog instanication
  SDK.config =
     credentials: new SDK.SharedIniFileCredentials {profile}
     region: config.aws.region
     sslEnabled: true
  config.sundog = Sundog(SDK).AWS

  # Top level IDs.  Names are by convention.
  config.accountID = (await config.sundog.STS().whoAmI()).Account
  config.gatewayName = config.stackName = "#{name}-#{env}"
  config.roleName = "#{capitalize name}#{capitalize env}LambdaRole"
  config.policyName = "#{name}-#{env}"

  config

export default check
