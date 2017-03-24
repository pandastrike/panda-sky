# Mango uses the AWS-SDK and your credentials to directly interact with Amazon.
{join} = require "path"
{homedir} = require "os"

AWS = require "aws-sdk"

{async, read, isFunction, where, lift} = require "fairmont"
{task} = require "panda-9000"

# this should be in f-core
bind = (o, f) -> f.bind o

liftModule = (m) ->
  lifted = {}
  for k, v of m
    lifted[k] = if isFunction v then (lift v.bind m) else v
  lifted

parseCreds = (data) ->
  lines = data.split "\n"
  get = (line) -> line.split(/\s*=\s*/)[1]
  where = (phrase) ->
    for i in [0...lines.length]
      return i if lines[i].indexOf(phrase) >= 0

  id: get lines[where "aws_access_key_id"]
  key: get lines[where "aws_secret_access_key"]

# Looks for AWS credentials stored at ~/.aws/credentials
awsPath = join homedir(), ".aws", "credentials"

module.exports = (region) ->
  # Module's we'd like to invoke from AWS are listed and lifted here.
  acm = liftModule new AWS.ACM()
  gw = liftModule new AWS.APIGateway()
  cfo = liftModule new AWS.CloudFormation()
  cfr = liftModule new AWS.CloudFront()
  route53 = liftModule new AWS.Route53()
  s3 = liftModule new AWS.S3()

  {acm, gw, cfo, cfr, route53, s3}
