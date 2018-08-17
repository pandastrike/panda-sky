# Panda Sky uses the AWS-SDK and your credentials to directly interact with Amazon.
{homedir} = require "os"

SDK = require "aws-sdk"

{async, read, isFunction, where, lift, bind} = require "fairmont"

liftModule = (m) ->
  lifted = {}
  for k, v of m
    lifted[k] = if isFunction v then lift bind v, m else v
  lifted

module.exports = (region, profile="default") ->
  SDK.config =
     credentials: new SDK.SharedIniFileCredentials {profile}
     region: region
     sslEnabled: true

  # Module's we'd like to invoke from AWS are listed and lifted here.
  acm = liftModule new SDK.ACM()
  agw = liftModule new SDK.APIGateway()
  gw = liftModule new SDK.APIGateway()
  cfo = liftModule new SDK.CloudFormation()
  cfr = liftModule new SDK.CloudFront()
  lambda = liftModule new SDK.Lambda()
  logs = liftModule new SDK.CloudWatchLogs()
  route53 = liftModule new SDK.Route53()
  s3 = liftModule new SDK.S3()
  ec2 = liftModule new SDK.EC2()
  sts = liftModule new SDK.STS()


  {AWS:SDK, acm, agw, gw, cfo, cfr, lambda, logs, route53, s3, ec2, sts}
