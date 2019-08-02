import {dashed, merge} from "panda-parchment"

Dispatch = (config) ->
  {region, accountID, name, env, environment} = config
  {stack, dispatch} = environment

  if dispatch?
    {lambda, variables, mixins} = dispatch

  if lambda?
    {runtime, memorySize, timeout, managedPolicies, vpc, preheater} = lambda

  name = dashed "#{name} #{env} dispatch"

  config.environment.dispatch =
    name: name
    runtime: runtime ? "nodejs8.10"
    memorySize: memorySize ? 256
    timeout: timeout ? 60
    preheater: preheater
    variables: merge name: config.name, environment: env, variables
    code:
      bucket: stack.bucket
      key: "package.zip"
    arn: "arn:aws:lambda:#{region}:#{accountID}:function:#{name}"
    hostname: config.environment.cache.origin
    hostedzone: environment.hostedzone
    certificate: environment.certificate
    zone1: region + "a"#vpc.availabilityZones[0]
    zone2: region + "b"#vpc.availabilityZones[1]
    managedPolicies: managedPolicies ? []
    mixins: mixins
    policy: [
      Effect: "Allow"
      Action: [
        "logs:CreateLogGroup"
        "logs:CreateLogStream"
        "logs:PutLogEvents"
      ]
      Resource: [ "arn:aws:logs:*:*:log-group:/aws/lambda/#{name}:*" ]
    ]

  if vpc
    config.environment.dispatch.managedPolicies.push "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"

    config.environment.dispatch.vpc =
      zone1: region + vpc.availabilityZones[0]
      zone2: region + vpc.availabilityZones[1]
      tags: do ->
        values = merge Name:name, environment:config.env, vpc.tags
        {Key, Value} for Key, Value of values

  config

export default Dispatch
