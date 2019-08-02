
Partitions = (config) ->

  for _name, {lambda} of config.environment.partitions

    if lambda.preheater
      name = "#{lambda.name}-preheat"

      config.environment.partitions[_name].preheater =
        name: name
        scale: lambda.preheater
        targets: [config.environment.dispatch.name, lambda.name]
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
          Resource: [
            lambda.arn
            config.environment.dispatch.arn
          ]
        ]


  config

export default Partitions
