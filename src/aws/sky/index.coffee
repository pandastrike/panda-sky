# Just like the other modules in "src/aws" wrap AWS APIs, this wraps a
# Panda Sky stack resource.  While we rely on AWS and CloudFormation to do most
# of the heavy lifting, we still have to do some orchestration here.  This
# provides handles for CFo description generation, access to the source bucket
# we use to track the stack's metadata, and direct access to the deployment's
# handlers for fast-updates directly to the Lambdas.
{async, exists} = require "fairmont"
{join} = require "path"

lambda = require "./lambda"
meta = require "./meta"
resources = require "./resource-tiers"
stack = require "./stack"

module.exports = async (env, config) ->
  s = {}
  s.env = env
  s.config = config
  s.stackName = "#{config.name}-#{env}"
  s.srcName = "#{env}-#{config.projectID}"
  s.bucket = yield require("../s3")(env, config, s.srcName)
  s.lambda = yield require("../lambda")(config)
  s.pkg = join process.cwd(), "deploy", "package.zip"
  s.apiDef = join process.cwd(), "api.yaml"
  s.skyDef = join process.cwd(), "sky.yaml"
  s.resources = resources

  throw new Error("Unable to find deploy/package.zip") if !(yield exists s.pkg)
  throw new Error("Unable to find api.yaml") if !(yield exists s.apiDef)
  throw new Error("Unable to find sky.yaml") if !(yield exists s.skyDef)

  lambda: lambda s
  meta: meta s
  stack = stack s
