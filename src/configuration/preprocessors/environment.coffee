# This checks that the developer's selected environment is valid and sets some smart defaults for the Lambda resources.
import SDK from "aws-sdk"
import Sundog from "sundog"
import {keys, captialize, camelCase} from "panda-parchment"

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

  # Confirm we have a TLS certificate for this domain.
  acm = config.sundog.ACM region: "us-east-1"
  unless config.environment.certificate = await acm.fetch config.domain
    throw new Error "unable to find wildcard TLS cert for #{config.domain}"

  # Confirm we have access to this domain's DNS records.
  route53 = config.sundog.Route53()
  unless config.environment.hostedzone = await route53.hzGet config.domain
    throw new Error "unable to find hostedzone ID for #{config.domain}"

  # Confirm we have API key for this environment in ASM.
  try
    asm = config.sundog.ASM()
    _name = capitalize camelCase "#{name} #{env} api key"
    {ARN} = await asm.get _name
    config.environment.apiKey = "{{resolve:secretsmanager:#{ARN}:SecretString}}"
  catch e
    throw new Error "unable to find API Key secret for #{env}"

  # Top level IDs.
  config.accountID = (await config.sundog.STS().whoAmI()).Account

  config

export default check
