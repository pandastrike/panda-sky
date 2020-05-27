import {dashed, include} from "panda-parchment"

Preheat = (config) ->
  {worker} = config.environment

  if worker.schedule
    name = dashed "#{config.name} #{config.env} worker #{worker.name} schedule"

    if minutes = worker.schedule.rate
      if minutes == 1
        scheduleExpression = "rate(1 minute)"
      else
        scheduleExpression = "rate(#{minutes} minutes)"
    else if cron = worker.schedule.cron
      scheduleExpression = "cron(#{cron})"
    else
      console.error schedule: worker.schedule
      throw new Error "unknown schedule expression"


    include config.environment.worker.lambda,
      schedule:
        name: name
        scheduleExpression: scheduleExpression
        targets: [worker.lambda.name]
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
          Resource: [ worker.lambda.arn ]
        ]

  config

export default Preheat
