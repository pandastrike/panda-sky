# A scan of the current domain configuration and available AWS resources is
# needed to confirm that Sky can accomplish the requested operation.

validate = (config, bucket) ->
  name = if config.aws.hostnames then config.aws.hostnames[0] else false
  {regularlyQualify, root} = config.sundog.URL
  {hzGet} = config.sundog.Route53()
  {fetch} = config.sundog.ACM {region:"us-east-1"} # quirk of how sky uses ACM

  # Check to make sure a hostname is specified
  fail hostnameMSG config.env if !name

  # Check to make sure a public hosted zone exists to support that hostname
  fail domainMSG name if !await hzGet name

  # Check to make sure we have the ACM cert for that domain
  domain = regularlyQualify root name
  fail ACMMSG name if !await fetch domain

  # Check to make sure we have deployment for this hostname
  fail deploymentMSG config.env if !await bucket.getState()


fail = (msg) ->
  console.error msg
  console.error "This process will now discontinue.\nDone.\n"
  process.exit()

hostnameMSG = (env) -> """
ERROR: There is no hostname set for this environment, #{env}
  Within your sky.yaml file, there is a stanza aws.environments.#{env}
  That stanza should include a "cache.hostnames" stanza where you specify
  the name of the custom domain resource you wish to deploy.  Sky does not
  support apex domains, ie: example.com

  Please set the configuration in sky.yaml and try again.
"""

domainMSG = (name) -> """
ERROR: The public hosted zone for  #{name} is not detected
  within your AWS account.  In Route53, please setup a public hosted zone
  using your desired domain and try again.
"""

ACMMSG = (name) -> """
ERROR: The TLS certificate for the domain #{name} is not
  detected within the "us-east-1" region and/or your AWS account.

  Such certificates can be created and maintained for free within the Amazon
  Certificate Manager, ACM.  Please setup a TLS certificate within the
  "us-east-1" AWS region for this domain and try again.
"""

deploymentMSG = (env) -> """
ERROR: There is no Sky deployment detected for this environment.  Sky Custom
  domains use AWS CloudFront to provide functionality, and they require a
  source URL.  Sky calculates that for you, but it must have a confirmed Sky
  deployment so it may target Gateway URL for you.  Please use "sky publish
  #{env}" to create a Sky deployment and try again.
"""

export default validate
