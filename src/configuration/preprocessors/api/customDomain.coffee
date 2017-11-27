# Take the high-level configuration from the user and apply a custom domain
# to the developer's Gateway deployment.
{async, empty} = require "fairmont"
{randomKey} = require "key-forge"

module.exports = async (description) ->
  {env, aws} = description
  desired = aws.environments[env]
  acm = yield do require "../../../aws/acm"
  {regularlyQualify, fullyQualify} = do require "../../../aws/url"

  if !desired.cache || empty aws.hostnames # No custom domains
    description.aws.customDomain = false
  else
    # Construct a configuration object that will be used to render CFr distro...
    description.aws.customDomain =
      CertificateArn: yield acm.fetch aws.hostnames[0]
      DomainName: aws.hostnames[0]
      route53:
        domain: fullyQualify aws.domain
        hostnames: fullyQualify n for n in aws.hostnames

  description
