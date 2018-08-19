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
{async, merge, capitalize, empty, keys} = require "fairmont"
{yaml} = require "panda-serialize"

# Helpers
{renderCore, renderTopLevel} = require "./api-core"
{renderMixins} = require "./mixins"

# The complete and rendered CloudFormation Description.
renderTemplate = async (config) ->
  # Get the mixin resources
  mixins = yield renderMixins config
  # Don't put mixin substack in top level if there are no resources to render.
  config.needsMixinResources = !(empty keys mixins)


  # Get the "core" sky deployment stuff, lambdas and their HTTP interface
  top = yield renderTopLevel config
  core = yield renderCore config

  # Return the rendered chunks to the configuration compiler top-level.
  {top, core, mixins}

module.exports = {
  renderTemplate
}
