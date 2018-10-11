# This assembles the CloudFormation Description for core features of a Panda
# Sky deployment, the API Gateway and Lambdas that back it.

# Libraries
import {resolve} from "path"
import {keys, empty, capitalize, camelCase, plainText, merge} from "panda-parchment"
import {yaml} from "panda-serialize"
import SDK from "aws-sdk"

# Helper Classes
import Templater from "../../templater"

# Paths
skyRoot = resolve __dirname, "..", "..", "..", "..", ".."
mixinPath = resolve skyRoot, "templates", "stacks", "mixins", "index.yaml"

render = (path, config) ->
  template = await Templater.read path
  template.render config

renderMixinRoot = (config) ->
  await render mixinPath, config

# Place the rendered resources from the mixin into a blank CloudFromation shell to form the final template.
finishTemplate = (resources, name, vpc) ->
  final =
    AWSTemplateFormatVersion: "2010-09-09"
    Description: "Panda Sky - #{capitalize name} Mixin Substack"
    Resources: resources
    Parameters:
      LambdaRole:
        Type: "String"
        Description: "ARN of IAM role used by Lambdas."

  if vpc
    final.Parameters = merge final.Parameters,
      VPC:
        Type: "String"
        Description: "VPC ID for this deployment"
      AvailabilityZones:
        Type: "String"
        Description: "comma delimited list of availability zones for the core stack VPC"
      SecurityGroups:
        Type: "String"
        Description: "comma delimited list of security groups for the core stack VPC"
      Subnets:
        Type: "String"
        Description: "comma delimited list of subnet IDs for the core stack VPC"

  yaml final

# Mixins have their own configuration schema and templates.  Validation and rendering is handled internally.  Just accept what we get back.  Not every mixin will actually need to deploy resources in this stack, so only index them if they do.
renderMixins = (config) ->
  bucket = config.environmentVariables.skyBucket
  SDK.config =
    credentials: new SDK.SharedIniFileCredentials {profile: config.profile}
    region: config.aws.region
    sslEnabled: true
  stacks = {}

  for name, m of config.mixins
    out = await m.render SDK, config  # optional object of needed resources.
    stacks[name] = (finishTemplate out, name, config.aws.vpc) if out

  if !(empty keys stacks)
    mixins =
      for name in keys stacks
        title: capitalize camelCase plainText name
        file: name
    stacks.index = await renderMixinRoot {mixins, bucket, vpc: config.aws.vpc}
  stacks

export {renderMixins}
