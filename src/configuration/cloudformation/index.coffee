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

# Constants
AWSTemplateFormatVersion = "2010-09-09"

# Helpers
{renderAPI} = require "./api-core"

# Finds and renders the API description and all mixins as the Resources.
renderResources = async (config) ->
  {AWS} = yield require("../../aws")(config.aws.region)
  resources = []
  resources.push yield renderAPI config

  # Mixins have their own configuration schema and templates.  Validation and
  # rendering is handled internally.  Just accept what we get back.
  resources.push yield m.render AWS, config for name, m of config.mixins

  merge resources...

# The complete and rendered CloudFormation Description. Object not string.
renderTemplate = async (config) ->
  Description = config.description || "#{config.name} - deployed by Panda Sky"
  Resources = yield renderResources config

  # These fields are the high level sections of a CloudFormation pattern.
  return {
    AWSTemplateFormatVersion
    Description
    Resources
  }

module.exports = {
  AWSTemplateFormatVersion
  renderTemplate
}
