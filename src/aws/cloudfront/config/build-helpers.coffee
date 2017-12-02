AWS = require "../../index"

module.exports = (sky) ->

  buildOrigins = async (originID) ->
    Quantity: 1
    Items: [
      Id: originID
      DomainName: yield s.meta.current.fetch().endpoint
      CustomHeaders:
        Quantity: 0
        Items: []
      OriginPath: "/#{sky.env}"
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

  setViewerCertificate = async (name) ->
    cert = yield acm.fetch name

    ACMCertificateArn: cert
    SSLSupportMethod: 'sni-only'
    MinimumProtocolVersion: sky.config.aws.cache.protocol
    Certificate: cert
    CertificateSource: 'acm'


  {buildOrigins, etViewerCertificate}
