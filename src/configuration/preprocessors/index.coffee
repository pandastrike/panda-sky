# Sky tries to accept only simple configuration and then apply them in a clever
# way to AWS.  That requires building up the more detialed configuration the
# underlying configuraiton requires.  These preprocessors do quite a bit to
# add that layer of sophistication.

{async, capitalize} = require "fairmont"
extractPaths = require "./paths"
extractResources = require "./resources"
extractMethods = require "./methods"
addTags = require "./tags"
extractDomains = require "./custom-domains"
addResponses = require "./responses"
addVariables = require "./variables"
addPolicyStatements = require "./policy-statements"
fetchMixins = require "./mixins"

module.exports = async (config) ->
  {name, env} = config
  config.gatewayName = "#{name}-#{env}"
  config.roleName = "#{capitalize name}#{capitalize env}LambdaRole"
  config.policyName = "#{name}-#{env}"

  # Add in default tags.
  config = addTags config

  # Apply default configuration to custom domain configuration
  config = extractDomains config

  # Extract path from configuration
  config = extractPaths config

  # Add environment varialbles that are injected into every Lambda.
  config = addVariables config

  # Build up resource array that includes virtual resources needed by Gateway.
  config = extractResources config

  # Compute the formatted template names for API action defintions.
  config = extractMethods config

  # Add the possible HTTP responses to every API action specification.
  config = addResponses config

  # Add base Sky policy statements that give Lambdas access to AWS resources.
  config = addPolicyStatements config

  # Remove the root resource, because it needs special handling
  rootKey = config.rootResourceKey
  delete config.resources[rootKey]
  delete config.rootResourceKey

  # Fetch the declared mixins installed in the project directory and instantiate
  # their CLI and render interfaces.
  config = yield fetchMixins config

  config
