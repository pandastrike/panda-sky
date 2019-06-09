import {first, rest, plainText, camelCase, dashed, capitalize, toUpper, toLower} from "panda-parchment"

templateCase = (string) -> capitalize camelCase plainText string

# Cycle through the methods on every resource and generate their algorithmic
# names.  This includes CFo template names as well as lambda
# defintion names.  These names are attached to the resource methods
# as implict properties and applied in the templates. Also, we attach the relevant resource index allowing us to reference a method's Gateway resource that resides in another template.
Methods = (description) ->
  {resources, env} = description
  appName = description.name

  for resourceName, resource of resources
    methods = ["OPTIONS"]
    for methodName, method of resource.methods
      templateName = templateCase "#{resourceName} #{methodName}"
      lambdaName = dashed "#{appName} #{env} #{resourceName} #{methodName}"

      methods.push methodName
      method.name = toUpper methodName
      method.parameters = resource.parameters
      method.resourceIndex = resource.index
      method.templateName = "#{templateName}Method"
      method.lambda =
        handler:
          name: "#{templateName}LambdaHandler"
          bucket: description.environmentVariables.skyBucket
        permission:
          name: "#{templateName}LambdaPermission"
          path: "/*/#{toUpper methodName}#{resource.permissionsPath}"
        "function":
          name: lambdaName
          arn: "arn:aws:lambda:#{description.aws.region}:#{description.accountID}:function:#{lambdaName}"

    resource.methodList = toUpper methods.join ", "

  description

export default Methods
