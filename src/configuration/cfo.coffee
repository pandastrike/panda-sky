#===============================================================================
# CFo Template Configuration
# Pull in the main API definition and assorted mixins to generate a
# CloudFormation template.  Each mixin's template is merged into a large CFo
# template that is attached to the main configuration object.
#===============================================================================
{join, resolve} = require "path"
{async, read, merge} = require "fairmont"
{yaml} = require "panda-serialize"
_render = require "panda-template"
preprocessors = require "./preprocessors"

module.exports = async (config, env) ->

  globals = {
    env,
    name: config.name,
    description: config.description,
    region:config.aws.region
  }

  # Each mixin has a template that gets rendered before joining the others.
  render = async (mixin, path) ->
    template = yield read join(__dirname, "..", "..", "mixins", "#{mixin}.yaml")
    data = yaml yield read resolve join(process.cwd(), path)
    data = yield preprocessors[mixin] merge data, globals
    yaml _render template, data

  # Compile a CFo template using the API base and all specified Mango mixins.
  mixins = []
  mixins.push(yield render(mixin, path)) for mixin, path of config.aws.mixins
  cfo =
    AWSTemplateFormatVersion: "2010-09-09"
    Description: config.description || "#{config.name} - deployed by Mango"
    Resources: merge mixins...

  # Add the stringified, rendered CloudFormation template to the config object.
  config.aws.cfoTemplate = JSON.stringify cfo
  config
