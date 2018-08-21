# Developers may specify a VPC to be associated with their deployment's core Lambdas.  That may be specified as either a new VPC, or an existing one by referencing its subnet and security group IDs.

{merge} = require "fairmont"

module.exports = (config) ->
  config.managedPolicies = []
  config.aws.vpc = false
  if vpc = config.aws.environments[config.env].vpc
    config.managedPolicies.push "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
    if vpc.override
      # Since this VPC already exists, we need to put the input subnets and security groups into a form that CloudFormation can consume directly.
      config.aws.vpc = merge vpc,
        new: false
        subnets: vpc.override.subnets.join ","
        securityGroups: vpc.override.securityGroups.join ","
    else
      config.aws.vpc = merge vpc,
        new: true
        zone1: config.aws.region + vpc.availabilityZones[0]
        zone2: config.aws.region + vpc.availabilityZones[1]



  config
