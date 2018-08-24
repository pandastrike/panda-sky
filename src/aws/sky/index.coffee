# Just like the other modules in "src/aws" wrap AWS APIs, this wraps a
# Panda Sky stack resource.  While we rely on AWS and CloudFormation to do most
# of the heavy lifting, we still have to do some orchestration here.  This
# provides handles for CFo description generation, access to the source bucket
# we use to track the stack's metadata, and direct access to the deployment's
# handlers for fast-updates directly to the Lambdas.
{async, exists} = require "fairmont"

variables = require "./variables"
domain = require "./domain"
lambdas = require "./lambdas"
meta = require "./meta"
stack = require "./stack"

module.exports = async (env, config) ->
  s = variables env, config

  # Confirm it's safe to proceed with the Sky Stack instanciation.
  throw new Error("Unable to find deploy/package.zip") if !(yield exists s.pkg)
  throw new Error("Unable to find api.yaml") if !(yield exists s.apiDef)
  throw new Error("Unable to find sky.yaml") if !(yield exists s.skyDef)

  # Wrappers around the AWS service APIs
  s.acm = yield require("../acm")(config)
  s.cfo = yield require("../cloudformation")(env, config, s.stackName)
  s.cfr = yield require("../cloudfront")(s)
  s.bucket = yield require("../s3")(env, config, s.srcName)
  s.lambda = yield require("../lambda")(config)
  s.eni = yield require("../eni")(config)
  s.route53 = yield require("../route53")(s)
  s.logs = yield require("../logs")(env, config)

  # Stack sub-resources
  s.domain = domain s
  s.lambdas = lambdas s
  s.meta = meta s
  s.stack = stack s

  # Exposed Sky Stack properties.
  cfo: s.cfo
  domain: s.domain
  lambdas: s.lambdas
  meta: s.meta
  stack: s.stack
  srcName: s.srcName
