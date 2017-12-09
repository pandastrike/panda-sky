module.exports = [
  {
    Effect: "Allow"
    Action: [
      "logs:CreateLogGroup"
      "logs:CreateLogStream"
      "logs:PutLogEvents"
    ]
    Resource: [
      "arn:aws:logs:*:*:*"
    ]
  },{
    Effect: "Allow"
    Action: [
      "s3:*"
    ]
    Resource: [
      "arn:aws:s3:::*"
    ]
  }
]
