import {join} from "path"
import {dashed, merge, toJSON} from "panda-parchment"

Dispatch = (config) ->
  {region, accountID} = config
  {lambda, variables, mixins, tags, name:workerName} = config.environment.worker

  if lambda?
    {runtime, memorySize, timeout, managedPolicies, trace, layers} = lambda

  name = dashed "#{config.name} #{config.env} worker #{workerName}"

  config.environment.worker.lambda =
    name: name
    workerName: workerName
    runtime: runtime ? "nodejs12.x"
    memorySize: memorySize ? 256
    timeout: timeout ? 60
    variables: merge name: config.name, environment: config.env, variables
    layers: layers
    trace: if trace then "Active" else "PassThrough"
    tags: tags
    code:
      bucket: config.environment.stack.bucket
      key: join "worker-code", "#{workerName}.zip"
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

  if trace
    config.environment.worker.lambda.trace = "Active"
    config.environment.worker.lambda.managedPolicies
      .push "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  else
    config.environment.worker.lambda.trace = "PassThrough"

  if config.environment.worker.workers?
    config.environment.worker.lambda.policy.push
      Effect: "Allow"
      Action: ["lambda:InvokeFunction"]
      Resource: do ->
        for worker in config.environment.worker.workers
          fnName = dashed "#{config.name} #{env} worker #{worker}"
          "arn:aws:lambda:#{region}:#{accountID}:function:#{fnName}"

  config

export default Dispatch
