{resolve} = require "path"
{async, read, merge, keys} = require "fairmont"
{yaml} = require "panda-serialize"
cloudformation = require("./cloudformation")

compile = async (appRoot, env) ->
  config = yield readApp appRoot
  checkEnv env, config

  # Setup the custom url config based on the selected environment.
  config = require("./url")(config, env)

  # Add default tags to the optional tags set by the user.
  config = require("./tags")(config, env)

  # Apply API and mixin definitions to generate a CloudFormation template.
  globals = merge config, {env}
  cfoTemplate = yield cloudformation.renderTemplate appRoot, globals
  config.aws.cfoTemplate = JSON.stringify cfoTemplate

  config

readApp = async (appRoot) ->
  try
    config = yaml yield read resolve appRoot, "sky.yaml"
  catch e
    throw new Error "There was a problem reading this project's configuration: #{e}"
  config

# Confirm the environment selected by the developer is present in configuration.
checkEnv = (env, config) ->
  available = keys config.aws.environments
  if env not in available
    msg = """
    WARNING: The provided environment, "#{env}", is not present in your sky.yaml
      configuration.  The available environments are:
    """
    msg += "\n=========================="
    msg += "\n    #{e}" for e in available
    msg += "\n=========================="
    msg += """
      \n\nPlease select from those or configure your desired environment.
      Done.
    """
    console.error msg
    process.exit()

module.exports = {
  compile
  readApp
}
