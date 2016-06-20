# The configuration for mango deployments is broken into several files for make
# it more managable for humans.  But, we need to assemble it all into one
# configuration object when it's time to use it.
{readFileSync} = require "fs"
{join, resolve} = require "path"

yaml = require "js-yaml"
{collect, where, empty} = require "fairmont"

module.exports = (env) ->
  config = require "./read"
  out = config
  env = config.aws.environments[env]
  out.aws.api = env.api if env.api
  out.aws.frontend = env.frontend if env.frontend


  # Add the CloudFormation template to the object.
  path = resolve join process.cwd(), env.api.cfo
  out.aws.cfoTemplate = JSON.stringify yaml.safeLoad readFileSync path

  # Return the compiled config.
  out
