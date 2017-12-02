# This helper constructs a CloudFront distribution configuration.  It optionally
# accepts a pre-existing configuration to faciliate a deepEqual comparison for
# update detection. We take a high-level configuration from the devloper and
# fill in the gaps with Sky's opinionated defaults.
{randomKey} = require "key-forge"
Helpers = require "./build-helpers"

module.exports = (sky) ->
  cacheConfig = sky.config.aws.cache
  {buildOrigins,
  setViewerCertificate,
  setHeaderCacheConfiguration} = Helpers sky

  async (name, c={}) ->
    originID = "Sky-" + regularlyQualify name

    # Fill out configuration for CloudFront distribution... it's a doozy.
    c.CallerReference = c.CallerReference || "Sky " + randomKey 32
    c.Comment = "Origin is an API Gateway. Setup by PandaSky."
    c.Enabled = true
    c.PriceClass = "PriceClass_" + cacheConfig.priceClass
    c.ViewerCertificate = yield setViewerCertificate name
    c.HttpVersion = cacheConfig.httpVersion
    c.DefaultRootObject = ""

    c.Aliases =
      Quantity: 1
      Items: [ name ]

    c.Origins = c.Origins || yield buildOrigins originID

    c.DefaultCacheBehavior =
      TargetOriginId: originID
      SmoothStreaming: false
      MinTTL: 0
      MaxTTL: cacheConfig.expires
      DefaultTTL: cacheConfig.expires
      ViewerProtocolPolicy: "redirect-to-https"
      Compress: false
      ForwardedValues:
        Cookies:
          Forward: "all"
        Headers:
          Quantity: cacheConfig.headers.length
          Items: cacheConfig.headers
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
