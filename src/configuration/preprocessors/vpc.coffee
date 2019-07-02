# Developers may specify a VPC to be associated with a partition.

VPC = (config) ->
  for _, partition of config.environment.partitions
    if {vpc} = partition
      partition.managedPolicies ?= []
      partition.managedPolicies.push "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"

      partition.vpc =
        zone1: config.region + vpc.availabilityZones[0]
        zone2: config.region + vpc.availabilityZones[1]

  config

export default VPC
