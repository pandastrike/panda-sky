import {join} from "path"
import {dashed, merge, toJSON} from "panda-parchment"

managedPolicyARN = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

Dispatch = (config) ->
  {region, accountID} = config
  {lambda, variables, mixins, tags, type} = config.environment.edge

  if lambda?
    {runtime, memorySize, timeout, managedPolicies, trace, layers} = lambda

  name = dashed "#{config.name} #{config.env} edge #{type}"

  if type in ["viewer-request", "viewer-response"]
    memorySize = 128
    timeout = 5
  else
    memorySize ?= 256
    timeout ?= 60

  config.environment.edge.lambda =
    name: name
    type: type
    runtime: runtime ? "nodejs12.x"
    memorySize: memorySize
    timeout: timeout
    variables: merge name: config.name, environment: config.env, variables
    layers: layers
    trace: "PassThrough"
    tags: tags
    code:
      bucket: config.environment.stack.bucket
      key: join "edge-code", "#{type}.zip"
    arn: "arn:aws:lambda:#{region}:#{accountID}:function:#{name}"
    managedPolicies: managedPolicies ? []
    policy: [
      Effect: "Allow"
      Action: [
        "logs:CreateLogGroup"
        "logs:CreateLogStream"
        "logs:PutLogEvents"
      ]
      Resource: [ "arn:aws:logs:*:*:log-group:/aws/lambda/#{name}:*" ]
    ]

  if config.environment.edge.workers?
    config.environment.edge.lambda.policy.push
      Effect: "Allow"
      Action: ["lambda:InvokeFunction"]
      Resource: do ->
        for worker in config.environment.edge.workers
          fnName = dashed "#{config.name} #{config.env} worker #{worker}"
          "arn:aws:lambda:#{region}:#{accountID}:function:#{fnName}"

  unless managedPolicyARN in config.environment.edge.lambda.managedPolicies
    config.environment.edge.lambda.managedPolicies.push managedPolicyARN

  config

export default Dispatch
