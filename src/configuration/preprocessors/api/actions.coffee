{toLower, capitalize, first, toUpper} = require "fairmont"

# Cycle through the actions on every resource and generate their algorithmic
# names.  This includes CFo template names (CamelName) as well as lambda
# defintion names (dash-name).  These names are attached to the resource actions
# as implict properties and applied in the templates.
module.exports = (description) ->
  {resources, env} = description
  appName = description.name

  makeCamelName = (resource, action) ->
    out = capitalize toLower resource
    out += capitalize toLower action.method
    out

  makeDashName = (resource, method) ->
    out = toLower resource
    out += "-"
    out += toLower action.method
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
    for a, action of resource.actions
      action.method = capitalize action.method
      methods.push action.method
      action.camelName = makeCamelName r, action
      action.gatewayMethodName = "#{action.camelName}Method"
      action.dashName = makeDashName r, action

      action.parameters = resource.parameters
      if action.signature.request?
        action.requestModel = capitalize action.signature.request
      action.dependencies = dependencies action.signature
      action.lambda =
        handler:
          name: "#{action.camelName}LambdaHandler"
          bucket: description.environmentVariables.skyBucket
        permission:
          name: "#{action.camelName}LambdaPermission"
          path: "/*/#{action.method}#{resource.permissionsPath}"
        "function":
          name: "#{appName}-#{env}-#{action.dashName}"

    resources[r].methodList = toUpper methods.join ", "

  description.resources = resources
  description
