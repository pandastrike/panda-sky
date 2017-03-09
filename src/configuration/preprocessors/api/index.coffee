{async} = require "fairmont"
extractParamters = require "./parameters"
extractCFr = require "./cfr"
extractResources = require "./resources"
extractActions = require "./actions"

module.exports = async (description) ->
  # Extract path and querystring parameter configuration
  description = extractParamters description

  # Extract CloudFront configuration
  description = yield extractCFr description

  # Build up resource array that includes virtual resources needed by Gateway.
  description = yield extractResources description

  # Compute the formatted template names for API action defintions.
  description = yield extractActions description

  description
