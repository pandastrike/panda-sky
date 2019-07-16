import {dashed, merge} from "panda-parchment"

Dispatch = (config) ->
  {region, accountID, name, env, environment} = config
  {stack, partitions, dispatch} = environment
  {runtime, memorySize, timeout, variables} = dispatch if dispatch?

  name = dashed "#{name} #{env} dispatch"

  config.environment.dispatch =
    name: name
    runtime: runtime ? "nodejs8.10"
    memorySize: memorySize ? 256
    timeout: timeout ? 60
    variables: merge environment: env, variables
    code:
      bucket: stack.bucket
      key: "package.zip"
    arn: "arn:aws:lambda:#{region}:#{accountID}:function:#{name}"
    hostname: config.environment.cache.origin
    hostedzone: environment.hostedzone
    certificate: environment.certificate
    policy: [
      Effect: "Allow"
      Action: [
        "logs:CreateLogGroup"
        "logs:CreateLogStream"
        "logs:PutLogEvents"
      ]
      Resource: [ "arn:aws:logs:*:*:log-group:/aws/lambda/#{name}:*" ]
    ,
      Effect: "Allow"
      Action: [ "lambda:InvokeFunction" ]
      Resource: do -> partition.lambda.arn for _, partition of partitions
    ]

  config

export default Dispatch
