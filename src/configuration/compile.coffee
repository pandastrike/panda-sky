# The configuration for mango deployments is broken into several files for make
# it more managable for humans.  But, we need to assemble it all into one
# configuration object when it's time to use it.  Mango stores the requisite
# template pieces and applies them based on the description specification,
# assembling something CloudFormation can use.
{join, resolve} = require "path"
{async, read, merge} = require "fairmont"
{yaml} = require "panda-serialize"
_render = require "panda-template"

module.exports = async (env) ->
  config = yield require "./read"

  # Setup the custom url config based on the selected environment.
  if config.aws.environments?[env]
    desired = config.aws.environments[env]

    if desired.hostnames
      {domain} = config.aws
      throw new Error "Domain not provided for custom URL creation." if !domain
      hostnames = []
      hostnames.push "#{name}.#{domain}" for name in desired.hostnames
      config.aws.hostnames = hostnames
      config.aws.cache = desired.cache || {}


  #===================================================
  # CFo Template Configuration
  #===================================================
  globals = {env, name: config.name, description: config.description}

  # Each mixin has a template that gets rendered before joining the others.
  render = async (mixin, path) ->
    template = yield read join(__dirname, "..", "..", "mixins", "#{mixin}.yaml")
    data = yaml yield read resolve join(process.cwd(), path)
    data = merge data, globals
    yaml _render template, data

  # Compile a CFo template using the API base and all specified Mango mixins.
  mixins = []
  mixins.push(yield render(mixin, path)) for mixin, path of config.aws.mixins

  cfo =
    AWSTemplateFormatVersion: "2010-09-09"
    Description: config.description || "API for #{config.name} - deployed by Mango"
    Resources: merge mixins...

  # Add the stringified, rendered CloudFormation template to the config object.
  config.aws.cfoTemplate = JSON.stringify cfo
  #console.log JSON.stringify(cfo, null, 2)
  #process.exit()
  config
