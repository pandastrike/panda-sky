{async} = require "fairmont"
extractParamters = require "./parameters"
extractCFr = require "./cfr"
extractResources = require "./resources"
extractActions = require "./actions"
addResponses = require "./responses"
selectRuntime = require "./runtime"
addVariables = require "./variables"

module.exports = async (description) ->
  # Extract path and querystring parameter configuration
  description = extractParamters description

  # Extract CloudFront configuration
  description = yield extractCFr description

  # Build up resource array that includes virtual resources needed by Gateway.
  description = yield extractResources description

  # Compute the formatted template names for API action defintions.
  description = yield extractActions description

  # Add the possible HTTP responses to every API action specification.
  description = yield addResponses description

  # Select the runtime for the Lambda, setting a default if not set.
  description = yield selectRuntime description

  # Add environment varialbles that are injected into every Lambda.
  description = yield addVariables description

  description
