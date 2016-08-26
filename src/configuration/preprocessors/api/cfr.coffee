# Take the high-level configuration from the user and apply the annoyingly
# complex configuration to properly deploy a CloudFront distribution
{async, empty} = require "fairmont"
{randomKey} = require "key-forge"

module.exports = async (description) ->
  {env, aws} = description
  desired = aws.environments[env]
  acm = yield do require "../../../aws/acm"
  {regularlyQualify, fullyQualify} = do require "../../../aws/url"

  if !desired.cache || empty aws.hostnames # No CFr distro to setup
    description.aws.cloudfront = false
    description.aws.route53 = false
  else
    # Construct a configuration object that will be used to render CFr distro...
    description.aws.cloudfront =
      originID: "Sky-" + regularlyQualify aws.hostnames[0]
      priceClass: "PriceClass_" + (desired.cache.priceClass || "100")
      aliases: aws.hostnames
      cert: yield acm.fetch aws.hostnames[0]
      maxTTL: desired.cache.expires || 0

    # ...and the appropriate DNS records
    description.aws.route53 = {
      domain: fullyQualify aws.domain
      hostnames: fullyQualify n for n in aws.hostnames
    }

  description
