# The API is divided into partitions, where multiple API resources are dispatched by instances of the same lambda.  Configure each partition.
import {dashed, capitalize, plainText, camelCase} from "panda-parchment"

templateCase = (string) -> capitalize camelCase plainText string

Partitions = (config) ->
  {region, accountID} = config
  {skyBucket} = config.environment.variables

  for _name, partition of config.environment.partitions
    if (lambda = partition.lambda)?
      {runtime, memorySize, timeout} = lambda

    name = dashed "#{config.name} #{config.env} #{_name}"

    partition.lambda =
      name: name
      runtime: runtime ? "nodejs8.10"
      memorySize: memorySize ? 256
      timeout: timeout ? 60
      template: templateCase "#{name}Lambda"
      arn: "arn:aws:lambda:#{region}:#{accountID}:function:#{name}"
      policy: [
          Effect: "Allow"
          Action: [
            "logs:CreateLogGroup"
            "logs:CreateLogStream"
            "logs:PutLogEvents"
          ]
          Resource: [ "arn:aws:logs:*:*:log-group:/aws/lambda/#{name}:*" ]
      ]

  config

export default Partitions
