# The API is divided into partitions, where multiple API resources are dispatched by instances of the same lambda.  Configure each partition.
import {dashed, capitalize, plainText, camelCase, merge} from "panda-parchment"

templateCase = (string) -> capitalize camelCase plainText string

Partitions = (config) ->
  {region, accountID} = config
  {stack} = config.environment

  for _name, partition of config.environment.partitions
    {lambda, vpc} = partition
    if lambda?
      {runtime, memorySize, timeout, managedPolicies} = lambda

    name = dashed "#{config.name} #{config.env} #{_name}"

    partition.lambda =
      name: name
      runtime: runtime ? "nodejs8.10"
      memorySize: memorySize ? 256
      timeout: timeout ? 60
      template: templateCase "#{name}Lambda"
      arn: "arn:aws:lambda:#{region}:#{accountID}:function:#{name}"
      code:
        bucket: stack.bucket
        key: "package.zip"
      policy: [
          Effect: "Allow"
          Action: [
            "logs:CreateLogGroup"
            "logs:CreateLogStream"
            "logs:PutLogEvents"
          ]
          Resource: [ "arn:aws:logs:*:*:log-group:/aws/lambda/#{name}:*" ]
      ]
      managedPolicies: managedPolicies ? []

    if vpc
      partition.lambda.managedPolicies.push "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"

      partition.vpc =
        zone1: region + vpc.availabilityZones[0]
        zone2: region + vpc.availabilityZones[1]
        tags: do ->
          values = merge Name:name, environment:config.env, vpc.tags
          {Key, Value} for Key, Value of values


  config

export default Partitions
