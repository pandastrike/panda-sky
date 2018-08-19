# This assembles the CloudFormation Description for core features of a Panda
# Sky deployment, the API Gateway and Lambdas that back it.

# Libraries
{resolve} = require "path"
{async, keys, empty, capitalize, camelCase, plainText} = require "fairmont"
{yaml} = require "panda-serialize"

# Helper Classes
Templater = require "../../templater"

# Paths
skyRoot = resolve __dirname, "..", "..", ".."
mixinPath = resolve skyRoot, "templates", "stacks", "mixins", "index.yaml"

render = async (path, config) ->
  template = yield Templater.read path
  template.render config

renderMixinRoot = async (config) ->
  yield render mixinPath, config

# Mixins have their own configuration schema and templates.  Validation and rendering is handled internally.  Just accept what we get back.  Not every mixin will actually need to deploy resources in this stack, so only index them if they do.
renderMixins = async (config) ->
  bucket = config.environmentVariables.skyBucket
  {AWS} = yield require("../../aws")(config.aws.region)
  stacks = {}
  for name, m of config.mixins
    out = yield m.render AWS, config  # optional object of needed resources.
    if out
      stacks[name] = yaml
        AWSTemplateFormatVersion: "2010-09-09"
        Description: "Panda Sky - #{capitalize name} Mixin Substack"
        Resources: out

  if !(empty keys stacks)
    mixins =
      for name in keys stacks
        title: capitalize camelCase plainText name
        file: name
    stacks.index = yield renderMixinRoot {mixins, bucket}
  stacks

module.exports = {renderMixins}
