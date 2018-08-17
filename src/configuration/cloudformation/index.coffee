# CloudFormation Template Assembly.
# ==============================================================================
# Panda Sky leverages AWS CloudFormation to manage the deployment of Cloud
# resources.  This pulls in the developer's API defintion and other
# configuration to build a "CloudFormation Template". Because we use templatized
# versions of "CloudFormation Templates", we use the terminology CloudFormation
# Description to describe a fully rendered set of instructions for AWS.
#
# This top-level pulls in data to build a CloudFormation Description for both
# the core features of Panda Sky (Gateway + Labmda) and assorted mixins that
# have their own resource templates.  The core and mixin templates are merged
# into one large CloudFormation Description that gets deployed together by AWS.

# Libraries
{async, merge} = require "fairmont"

# Helpers
{renderCore, renderTopLevel} = require "./api-core"

# The complete and rendered CloudFormation Description. Object not string.
renderTemplate = async (config) ->
  coreStacks = yield renderCore config
  topLevelStack = yield renderTopLevel config

  # # Mixins have their own configuration schema and templates.  Validation and rendering is handled internally.  Just accept what we get back.
  # {AWS} = yield require("../../aws")(config.aws.region)
  # resources.push yield m.render AWS, config for name, m of config.mixins

  # Return the rendered chunks needed to make the deployment real.
  {coreStacks, topLevelStack}

module.exports = {
  renderTemplate
}
