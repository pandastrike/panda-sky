# A scan of the current domain configuration and available AWS resources is
# needed to confirm that Sky can accomplish the requested operation.
{async} = require "fairmont"
{regularlyQualify, root} = require "../../../url"

module.exports = (s) ->
  isViable: async (name) ->
    domain = regularlyQualify root name

    # Check to make sure a hostname is specified
    fail hostnameMSG s.env if !name

    # Check to make sure a CloudFront distro exists to support that hostname.
    fail CFMSG name if !yield s.cfr.get name


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
ERROR: The CloudFront distribution for  #{name} is not detected
  within your AWS account.  Invalidations can only be issued against existant
  Sky custom domain resources.
"""
