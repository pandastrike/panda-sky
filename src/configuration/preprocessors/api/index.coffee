{async} = require "fairmont"
extractParameters = require "./parameters"
extractCFr = require "./cfr"
extractResources = require "./resources"
extractActions = require "./actions"
addResponses = require "./responses"
selectRuntime = require "./runtime"
addVariables = require "./variables"

module.exports = async (mungedConfig) ->
  {name, env} = mungedConfig
  mungedConfig.gatewayName = "#{name}-#{env}"
  mungedConfig.policyName = "#{name}-#{env}"

  # Extract path and querystring parameter configuration
  mungedConfig = extractParameters mungedConfig

  # Add environment varialbles that are injected into every Lambda.
  mungedConfig = yield addVariables mungedConfig

  # Extract CloudFront configuration
  mungedConfig = yield extractCFr mungedConfig

  # Build up resource array that includes virtual resources needed by Gateway.
  mungedConfig = yield extractResources mungedConfig

  # Compute the formatted template names for API action defintions.
  mungedConfig = yield extractActions mungedConfig

  # Add the possible HTTP responses to every API action specification.
  mungedConfig = yield addResponses mungedConfig

  # Select the runtime for the Lambda, setting a default if not set.
  mungedConfig = yield selectRuntime mungedConfig

  mungedConfig
