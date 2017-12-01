# This helper constructs a CloudFront distribution configuration.  It optionally
# accepts a pre-existing configuration to faciliate a deepEqual comparison for
# update detection. We take a high-level configuration from the devloper and
# fill in the gaps with Sky's opinionated defaults.
{randomKey} = require "key-forge"
Helpers = require "./helpers"

module.exports = (skyConfig) ->

  async (name, c={}) ->
    {setViewerCertificate} = Helpers skyConfig, name
    originID = "Sky-" + regularlyQualify name

    applyDefaults = async (name) ->
      {ssl, priceClass, httpVersion} = config.aws.cache

      protocolPolicy: if ssl then "redirect-to-https" else "allow-all"
      priceClass: priceClass || "100"
      originID: "Haiku9-" + regularlyQualify name
      cert:
      headers: setHeaderCacheConfiguration()
      expires: config.aws.cache.expires || 60
      httpVersion: httpVersion || "http2"

    # Fill out configuration for CloudFront distribution... it's a doozy.
    c.CallerReference = c.CallerReference || "Sky " + randomKey 32
    c.Comment = "Origin is an API Gateway. Setup by PandaSky."
    c.Enabled = true
    c.PriceClass = "PriceClass_" + skyConfig.priceClass
    c.ViewerCertificate = yield setViewerCertificate()
    c.HttpVersion = skyConfig.httpVersion
    c.DefaultRootObject = ""

    c.Aliases =
      Quantity: 1
      Items: [ name ]

    c.Origins = c.Origins || buildOrigins(name, originID)

    c.DefaultCacheBehavior =
      TargetOriginId: originID
      SmoothStreaming: false
      MinTTL: 0
      MaxTTL: distro.expires
      DefaultTTL: distro.expires
      ViewerProtocolPolicy: distro.protocolPolicy
      Compress: false
      ForwardedValues:
        Cookies:
          Forward: "all"
        Headers: setHeaderCacheConfiguration()
        QueryString: true
        QueryStringCacheKeys:
          Quantity: 1
          Items: ["*"]
      TrustedSigners:
        Enabled: false
        Quantity: 0
        Items: []
      AllowedMethods:
        Items: [ "GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE" ]
        Quantity: 7
        CachedMethods:
          Items: [ "GET", "HEAD", "OPTIONS" ]
          Quantity: 3
      LambdaFunctionAssociations:
        Quantity: 0
        Items: []


    c
