
module.exports = (config) ->
  config.aws.vpc = false
  if vpcConfig = config.aws.environments[config.env].vpc
    config.aws.vpc = vpcConfig
    config.managedPolicies.push "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"


  config
