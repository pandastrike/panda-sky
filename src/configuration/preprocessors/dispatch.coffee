import {dashed, merge, toJSON} from "panda-parchment"
import elbAccountIDs from "../../../../../files/elb-account-ids.json"

Dispatch = (config) ->
  {region, accountID, name, env, environment} = config
  {stack, dispatch} = environment

  if dispatch?
    {lambda, variables, mixins} = dispatch

  if lambda?
    {runtime, memorySize, timeout, managedPolicies, vpc, preheater,
      trace, albLogging, layers} = lambda

  name = dashed "#{name} #{env} dispatch"

  config.environment.dispatch =
    name: name
    runtime: runtime ? "nodejs8.10"
    memorySize: memorySize ? 256
    timeout: timeout ? 60
    preheater: preheater
    variables: merge name: config.name, environment: env, variables
    layers: layers
    trace: if trace then "Active" else "PassThrough"
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

  if trace
    config.environment.dispatch.trace = "Active"
    config.environment.dispatch.managedPolicies
      .push "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  else
    config.environment.dispatch.trace = "PassThrough"

  if albLogging
    S3 = config.sundog.S3()
    bucket = "#{config.projectID}-#{config.env}-alb-access"

    await S3.bucketTouch bucket
    await S3.bucketSetPolicy bucket, toJSON
      Version: "2008-10-17"
      Statement: [
        Effect: "Allow"
        Principal:
          AWS: elbAccountIDs[config.region]
        Action: "s3:PutObject"
        Resource: "arn:aws:s3:::#{bucket}/AWSLogs/#{config.accountID}/*"
      ]

    config.environment.dispatch.albLogBucket = bucket


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
