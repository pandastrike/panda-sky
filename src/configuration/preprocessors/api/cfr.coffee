# Take the high-level configuration from the user and apply the annoyingly
# complex configuration to properly deploy a CloudFront distribution
{async, merge, deepEqual} = require "fairmont"
{randomKey} = require "key-forge"

module.exports = async (description) ->
  {env, aws} = description
  desired = aws.environments[env]
  acm = yield do require "../../../aws/acm"
  {regularlyQualify} = do require "../../../aws/url"

  if !desired.cache # No CFr distro to setup
    config = false
  else
    # Construct a configuration object that will be used to render CFr distro
    config =
      originID: "Sky-" + regularlyQualify aws.hostnames[0]
      priceClass: "PriceClass_" + (desired.cache.priceClass || "100")
      aliases: aws.hostnames
      cert: yield acm.fetch aws.hostnames[0]
      maxTTL: desired.cache.expires || 0

  description.aws.cloudfront = config
  description
