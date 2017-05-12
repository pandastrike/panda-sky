{toLower, capitalize, first, toUpper} = require "fairmont"

# Cycle through the methods on every resource and generate their algorithmic
# names.  This includes CFo template names (CamelName) as well as lambda
# defintion names (dash-name).  These names are attached to the resource methods
# as implict properties and applied in the templates.
module.exports = (description) ->
  {resources, env} = description
  appName = description.name

  makeCamelName = (resource, method) ->
    out = capitalize toLower resource
    out += capitalize toLower method.method
    out

  makeDashName = (resource, method) ->
    out = toLower resource
    out += "-"
    out += toLower method.method
    out

  hasDependency = (signature) ->
    if signature.request || signature.response then true else false

  dependencies = ({request, response}) ->
    result = []
    if request
      result.push "#{capitalize(request)}Resource"
      result.push "#{capitalize(request)}Model"
    if response
      result.push "#{capitalize(response)}Resource"
      result.push "#{capitalize(response)}Model"
    result

  for r, resource of resources
    methods = ["options"]
    for a, method of resource.methods
      method.method = capitalize method.method
      methods.push method.method
      method.camelName = makeCamelName r, method
      method.gatewayMethodName = "#{method.camelName}Method"
      method.dashName = makeDashName r, method

      method.parameters = resource.parameters
      if method.signature.request?
        method.requestModel = capitalize method.signature.request
      method.dependencies = dependencies method.signature
      method.lambda =
        handler:
          name: "#{method.camelName}LambdaHandler"
          bucket: description.environmentVariables.skyBucket
        permission:
          name: "#{method.camelName}LambdaPermission"
          path: "/*/#{method.method}#{resource.permissionsPath}"
        "function":
          name: "#{appName}-#{env}-#{method.dashName}"

    resources[r].methodList = toUpper methods.join ", "

  description.resources = resources
  description
