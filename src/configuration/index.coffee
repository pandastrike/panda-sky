{resolve} = require "path"
{async, read} = require "fairmont"
{yaml} = require "panda-serialize"
cloudformation = require("./cloudformation")

compile = async (env) ->
  config = yield readApp process.cwd()

  # IDEA: use fairmont.flow/go/pull
  #
  # Setup the custom url config based on the selected environment.
  config = require("./url")(config, env)

  # Add default tags to the optional tags set by the user.
  config = require("./tags")(config, env)

  # Apply API and mixin definitions to generate a CloudFormation template.
  config = yield cloudformation.transitional(config, env)

  config


readApp = async (appRoot) ->
  try
    config = yaml yield read resolve appRoot, "sky.yaml"
  catch e
    console.error "There was a problem reading this project's configuration.", e.message
    throw e
  config


module.exports = {
  compile
  readApp
}
