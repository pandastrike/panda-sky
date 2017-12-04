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
#{renderMixins} = require "./mixins" # TODO - handle mixins.

# Finds and renders the API description and all mixins as the Resources.
renderResources = async (appRoot, globals) ->
  resources = []
  resources.push yield renderAPI appRoot, globals
  #resources.push yield renderMixins appRoot, globals  # TODO - handle mixins.
  merge resources...

# The complete and rendered CloudFormation Description. Object not string.
renderTemplate = async (appRoot, globals) ->
  Description = globals.description || "#{globals.name} - deployed by Panda Sky"
  Resources = yield renderResources appRoot, globals

  return {
    AWSTemplateFormatVersion
    Description
    Resources
  }

module.exports = {
  AWSTemplateFormatVersion
  renderTemplate
}
