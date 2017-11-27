{async} = require "fairmont"
extractParameters = require "./parameters"
extractDomain = require "./customDomain"
extractResources = require "./resources"
extractMethods = require "./methods"
addResponses = require "./responses"
selectRuntime = require "./runtime"
addVariables = require "./variables"

module.exports = async (config) ->
  {name, env} = config
  config.gatewayName = "#{name}-#{env}"
  config.policyName = "#{name}-#{env}"

  # Extract path and querystring parameter configuration
  config = extractParameters config

  # Add environment varialbles that are injected into every Lambda.
  config = yield addVariables config

  # Extract custom domain configuration
  config = yield extractDomain config

  # Build up resource array that includes virtual resources needed by Gateway.
  config = yield extractResources config

  # Compute the formatted template names for API action defintions.
  config = yield extractMethods config

  # Add the possible HTTP responses to every API action specification.
  config = yield addResponses config

  # Select the runtime for the Lambda, setting a default if not set.
  config = yield selectRuntime config


  # Remove the root resource, because it needs special handling
  rootKey = config.rootResourceKey
  delete config.resources[rootKey]
  delete config.rootResourceKey

  config
