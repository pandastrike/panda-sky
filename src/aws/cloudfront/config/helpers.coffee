AWS = require "../../index"

module.exports = (skyConfig, name) ->
  buildSource = (name) ->
    name + ".s3-website-" + config.aws.region + ".amazonaws.com"

  setViewerCertificate = async ->
    {protocol} = skyConfig
    cert = yield acm.fetch name

    ACMCertificateArn: cert
    SSLSupportMethod: 'sni-only'
    MinimumProtocolVersion: protocol
    Certificate: cert
    CertificateSource: 'acm'


  setHeaderCacheConfiguration = ->
    {headers} = config.aws.cache

    if !headers || headers.length == 0
      # The field is unspecifed or declared explicitly to include no headers,
      # so we need to return 0 quantity.  Default forwarding with no caching.
      {Quantity: 0, Items: []}
    else if "*" in headers
      # Wildcard specificaton.  Everything gets forwarded with no caching.
      if headers.length == 1
        {Quantity: 1, Items: ["*"]}
      else
        throw new Error "Incorrect header specificaton.  Wildcard cannot be used with other named headers."
    else
      # Named, finite headers specified.  These get forwarded AND cached by CloudFront.
      {Quantity: headers.length, Items: headers}

  buildOrigins = (name, originID) ->
    Quantity: 1
    Items: [
      Id: originID
      DomainName: buildSource name
      CustomHeaders:
        Quantity: 0
        Items: []
      OriginPath: ""
      CustomOriginConfig:
        HTTPPort: 80
        HTTPSPort: 443
        OriginProtocolPolicy: "https-only"
        OriginSslProtocols:
          Quantity: 1
          Items: ["TLSv1.2"]
        OriginReadTimeout: 30
        OriginKeepaliveTimeout: 5
    ]



  {setViewerCertificate}
