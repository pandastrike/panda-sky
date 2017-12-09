{async, capitalize} = require "fairmont"
extractParameters = require "./parameters"
extractResources = require "./resources"
extractMethods = require "./methods"
addResponses = require "./responses"
addVariables = require "./variables"
policyStatements = require "./policy-statements"

module.exports = async (config) ->
  {name, env} = config
  config.gatewayName = "#{name}-#{env}"
  config.roleName = "#{capitalize name}#{capitalize env}LambdaRole"
  config.policyName = "#{name}-#{env}"
  config.policyStatements = policyStatements

  # Extract path and querystring parameter configuration
  config = extractParameters config

  # Add environment varialbles that are injected into every Lambda.
  config = yield addVariables config

  # Build up resource array that includes virtual resources needed by Gateway.
  config = yield extractResources config

  # Compute the formatted template names for API action defintions.
  config = yield extractMethods config

  # Add the possible HTTP responses to every API action specification.
  config = yield addResponses config


  # Remove the root resource, because it needs special handling
  rootKey = config.rootResourceKey
  delete config.resources[rootKey]
  delete config.rootResourceKey

  config
