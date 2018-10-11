import {cat} from "panda-parchment"

Statements = (config) ->
  {environmentVariables: {skyBucket}} = config
  throw new Error "Undefined Sky Bucket" if !skyBucket

  lambdaNames = cat (
    for r, resource of config.resources
      for m, method of resource.methods when method.lambda
        method.lambda.function.name
  )...

  buildARN = (n) -> "arn:aws:logs:*:*:log-group:/aws/lambda/#{n}:*"
  loggerResources = (buildARN n for n in lambdaNames)

  config.policyStatements = [
    {
      Effect: "Allow"
      Action: [
        "logs:CreateLogGroup"
        "logs:CreateLogStream"
        "logs:PutLogEvents"
      ]
      Resource: loggerResources
    },{
      Effect: "Allow"
      Action: [
        "s3:GetObject"
      ]
      Resource: [
        "arn:aws:s3:::#{skyBucket}/api.yaml"
      ]
    }
  ]

  config

export default Statements
