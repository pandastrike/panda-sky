import {toLower, capitalize, first, rest, toUpper} from "panda-parchment"
import {yaml} from "panda-serialize"

# Cycle through the methods on every resource and generate their algorithmic
# names.  This includes CFo template names (CamelName) as well as lambda
# defintion names (dash-name).  These names are attached to the resource methods
# as implict properties and applied in the templates.
Methods = (description) ->
  {resources, env} = description
  appName = description.name

  makeCamelName = (resource, method) ->
    out = capitalize toLower resource
    out += capitalize toLower method
    out

  makeDashName = (resource, method) ->
    out = toLower resource
    out += "-"
    out += toLower method
    out

  dependencies = ({request, response}) ->
    result = []
    if request?.resource?
      result.push "#{capitalize(request.resource)}Resource"
      result.push "#{capitalize(request.resource)}Model"
    if response?.resource?
      result.push "#{capitalize(response.resource)}Resource"
      result.push "#{capitalize(response.resource)}Model"
    result

  # This applies smart defaults for the request-response signature defintion.
  # This is for both the final stack configuration and the human-friendly API definition the api.yaml is used to build.
  applySignatureDefaults = (method) ->
    {signatures:{request, response}} = method

    # Right now, we only have basic support for request mediatypes.
    if request.schema
      request.schemaString = yaml request.schema
      if !request.mediatype
        method.signatures.request.mediatype = ["application/json"]
    if request.mediatype
      method.signatures.request.mediatypeString =  "[ \"#{request.mediatype.join "\", \""}\" ]"


    if !response.mediatype
      response.mediatype = ["application/json"]
    method.signatures.response.mediatypeString =  "[ \"#{response.mediatype.join "\", \""}\" ]"


    response.statusOK = first response.status
    if (rest response.status).length > 0
      response.statusBad = "[ \"#{(rest response.status).join "\", \""}\" ]"

    method


  for resourceName, resource of resources
    methods = ["OPTIONS"]
    for methodName, method of resource.methods
      method = applySignatureDefaults method

      methods.push methodName
      method.name = toUpper methodName
      camelized = makeCamelName resourceName, methodName
      dashed = makeDashName resourceName, methodName
      method.gateway =
        name: "#{camelized}Method"

      method.parameters = resource.parameters
      if method.signatures.request?.resource?
        method.requestModel = capitalize method.signatures.request.resource
      method.dependencies = dependencies method.signatures

      lambdaName = "#{appName}-#{env}-#{toLower resourceName}-#{toLower method.name}"

      method.lambda =
        handler:
          name: "#{camelized}LambdaHandler"
          bucket: description.environmentVariables.skyBucket
        permission:
          name: "#{camelized}LambdaPermission"
          path: "/*/#{toUpper methodName}#{resource.permissionsPath}"
        "function":
          name: lambdaName
          arn: "arn:aws:lambda:#{description.aws.region}:#{description.accountID}:function:#{lambdaName}"

    resource.methodList = toUpper methods.join ", "

  description

export default Methods
