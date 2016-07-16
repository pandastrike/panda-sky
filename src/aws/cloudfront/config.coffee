# This module handles a CFr distribution's annoyingly complex configuration.
{async, merge} = require "fairmont"
{randomKey} = require "key-forge"

module.exports = async (config, env) ->
  acm = yield require("../acm")(config)
  {regularlyQualify} = do require "../url"
  api = yield require("../gw")(config)

  # Functions to set various chunks of the CFr config.
  setViewerCertificate = async ->
    cert = yield acm.fetch config.aws.hostnames[0]

    ACMCertificateArn: cert
    SSLSupportMethod: 'sni-only'
    MinimumProtocolVersion: 'TLSv1'
    Certificate: cert
    CertificateSource: 'acm'


  setAliases = ->
    Quantity: config.aws.hostnames.length
    Items: config.aws.hostnames

  setOrigins = async (originID) ->
    Quantity: 1
    Items: [
      Id: originID
      DomainName: yield api.getEndpoint()
      OriginPath: "/#{env}"
      CustomOriginConfig:
        HTTPPort: 80
        HTTPSPort: 443
        OriginProtocolPolicy: "https-only"
        OriginSslProtocols:
          Quantity: 2
          Items: [ "SSLv3", "TLSv1" ]
    ]


  setDefaultCacheBehavior = (originID) ->
    TargetOriginId: originID
    ForwardedValues:
      QueryString: true
      Cookies:
        Forward: "all"
      Headers:
        Quantity: 3
        Items: [
          "Accept"
          "Authorization"
          "Content-Type"
        ]
    MinTTL: 0
    MaxTTL: config.aws.cache.expires || 0
    TrustedSigners:
      Enabled: false
      Quantity: 0
    ViewerProtocolPolicy: "redirect-to-https"
    AllowedMethods:
      Items: [ "GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE" ]
      Quantity: 7
      CachedMethods:
        Items: [ "GET", "HEAD", "OPTIONS" ]
        Quantity: 3
    Compress: false



  build = async ->
    # Target the API GW deployment that we've finished.
    originID = "Mango-" + regularlyQualify config.aws.hostnames[0]

    # return a configuration for CloudFront distribution... it's a doozy.
    CallerReference: "Mango" + randomKey 32
    Comment: "Origin is an API Gateway deployment. Setup by Mango."
    Enabled: true
    PriceClass: "PriceClass_" + (config.aws.cache.priceClass || "100")
    DefaultRootObject: ""

    Aliases: setAliases()
    Origins: yield setOrigins originID
    ViewerCertificate: yield setViewerCertificate()
    DefaultCacheBehavior: setDefaultCacheBehavior originID

  compare = (current, desired) ->
    return false if current.PriceClass != "PriceClass_" + (config.aws.cache.priceClass || "100")
    return false if current.DefaultCacheBehavior.MaxTTL != (config.aws.cache.expires || 0)
    return false if current.Aliases.Items != setAliases()
    return false if current.ViewerCertificate != yield setViewerCertificate()
    true

  deepMerge = (current, desired) ->
    # return a configuration for CloudFront distribution that's updated from the current.
    changes =
      PriceClass: "PriceClass_" + (config.aws.cache.priceClass || "100")
      DefaultRootObject: ""
      Aliases: merge current.Aliases, desired.Aliases
      ViewerCertificate: merge current.ViewerCertificate, desired.ViewerCertificate
      DefaultCacheBehavior: merge current.DefaultCacheBehavior, desired.DefaultCacheBehavior

    merge current, changes

  {build, compare, deepMerge}
