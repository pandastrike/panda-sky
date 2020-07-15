# This checks that the developer's selected environment is valid and sets some smart defaults for the Lambda resources.
import {flow} from "panda-garden"
import SDK from "aws-sdk"
import Sundog from "sundog"
import {keys, dashed} from "panda-parchment"

validate = (config) ->
  {env} = config

  if config.environments[env]
    config.environment = config.environments[env]
  else
    console.error """
      The environment "#{env}" is not present in your sky.yaml configuration.
      Available environments are:
      #{(keys config.environments).join ", "}
    """
    throw new Error "environment \"#{env}\" is not specified"

  config

getSDK = (config) ->
  {profile} = config
  config.sundog = Sundog
    credentials: new SDK.SharedIniFileCredentials {profile}
    region: config.region
    sslEnabled: true

  config

# Confirm we have a TLS certificate for this domain.
getCertificate = (config) ->
  acm = config.sundog.ACM region: "us-east-1"
  unless config.environment.certificate = await acm.fetch config.domain
    throw new Error "unable to find wildcard TLS cert for #{config.domain}"

  config


# Confirm we have access to this domain's DNS records.
getHostedZone = (config) ->
  route53 = config.sundog.Route53()
  unless config.environment.hostedzone = await route53.hzGet config.domain
    throw new Error "unable to find hostedzone ID for #{config.domain}"

  config


getAPIKey = (config) ->
  {name, env} = config
  try
    asm = config.sundog.ASM()
    name = dashed "#{name} #{env} api key"
    {ARN} = await asm.get name
    config.environment.apiKey =
      "{{resolve:secretsmanager:#{name}:SecretString:api}}"
  catch e
    console.log e
    throw new Error "unable to find API Key secret for #{env}"

  config


# Top level IDs.
getAccountID = (config) ->
  config.accountID = (await config.sundog.STS().whoAmI()).Account
  config

check = flow [
  validate
  getSDK
  getCertificate
  getHostedZone
  getAPIKey
  getAccountID
]

export default check

export {validate, getSDK, getCertificate, getHostedZone, getAPIKey, getAccountID}
