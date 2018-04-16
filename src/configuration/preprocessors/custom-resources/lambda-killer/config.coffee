# When Lambdas interface with a VPC, they setup ENIs that require about 40 minutes to gracefully drain and then close.  That can be important in some cases, but when the developer wants to quickly force its deletion, this custom resource is used.  This Lambda exists away from any VPC, targeting all Sky lambdas for "manual" deletion, before being destroyed by CloudFormation

{resolve} = require "path"
{async, read} = require "fairmont"
YAML = require "js-yaml"

module.exports = async (config) ->
  if !config.aws.vpc || !config.aws.vpc.skipConnectionDraining
    return config

  {skyBucket, fullName} = config.environmentVariables
  handlerName = "#{fullName}-custom-lambda-killer"

  Bucket = require "../../../../aws/s3"
  bucket = yield Bucket config.aws.region, config, skyBucket
  yield bucket.establish()
  yield bucket.putObject "lambda-killer.zip", resolve __dirname, "lambda-killer.zip"


  if !config.customResources
    config.customResources = []

  config.customResources.push YAML.safeDump
    LambdaKillerRole:
      Type: "AWS::IAM::Role"
      Properties:
        AssumeRolePolicyDocument:
          Version: "2012-10-17"
          Statement: [
            Effect: "Allow"
            Principal:
              Service: ["lambda.amazonaws.com"]
            Action: ["sts:AssumeRole"]
          ]
        Policies: [
          PolicyName: "#{config.fullName}-lambda-killer-policy"
          PolicyDocument:
            Version: "2012-10-17"
            Statement: [
              {
                Effect: "Allow"
                Action: [
                  "logs:CreateLogGroup"
                  "logs:CreateLogStream"
                  "logs:PutLogEvents"
                ]
                Resource: [
                  "arn:aws:logs:*:*:log-group:/aws/lambda/#{handlerName}:*"
                ]
              },{
                Effect: "Allow"
                Action: [
                  "s3:GetObject"
                ]
                Resource: [
                  "arn:aws:s3:::#{skyBucket}/api.yaml"
                ]
              },{
                Effect: "Allow"
                Action: [
                  "lambda:DeleteFunction"
                ]
                Resource: [
                  "arn:aws:lambda:*:*"
                ]
              }
            ]
          ]

  config.customResources.push YAML.safeDump
    LambdaKillerFunction:
      Type: "AWS::Lambda::Function"
      Properties:
        Code:
          S3Bucket: skyBucket
          S3Key: "custom-resources/lambda-killer.zip"
        Handler: "#{handlerName}.handler"
        Runtime: "nodejs6.10"
        Timeout: 60
        Role: "Fn::GetAtt" : [ "LambdaKillerRole", "Arn" ]

  config.customResources.push YAML.safeDump
    LambdaKiller:
      Type: "Custom::LambdaKiller"
      Properties:
        ServiceToken: "Fn::GetAtt" : ["LambdaKillerFunction", "Arn"]
        Stackname: fullName

  config
