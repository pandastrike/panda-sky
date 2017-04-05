# The configuration for mango deployments is broken into several files for make
# it more managable for humans.  But, we need to assemble it all into one
# configuration object when it's time to use it.  Mango stores the requisite
# template pieces and applies them based on the description specification,
# assembling something CloudFormation can use.
{async} = require "fairmont"

module.exports = async (env) ->
  config = yield require "./read"

  # Setup the custom url config based on the selected environment.
  config = require("./url")(config, env)

  # Add default tags to the optional tags set by the user.
  config = require("./tags")(config, env)

  # Apply API and mixin definitions to generate a CloudFormation template.
  config = yield require("./cfo")(config, env)

  config
