
Preheat = (config) ->
  {dispatch} = config.environment

  if dispatch.preheater
    name = "#{dispatch.name}-preheat"

    config.environment.dispatch.preheater =
      name: name
      scale: dispatch.preheater
      targets: [dispatch.name]
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
        Resource: [ dispatch.arn ]
      ]

  config

export default Preheat
