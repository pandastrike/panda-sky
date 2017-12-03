{async} = require "fairmont"
AWS = require "../../index"

module.exports = (sky) ->

  buildOrigins = async (originID) ->
    {endpoint} = yield sky.meta.current.fetch()
    endpoint = endpoint.split("/#{sky.env}")[0]
    endpoint = endpoint.split("://")[1]

    Quantity: 1
    Items: [
      Id: originID
      DomainName: endpoint
      CustomHeaders:
        Quantity: 0
        Items: []
      OriginPath: "/#{sky.env}"
      CustomOriginConfig:
        HTTPPort: 80
        HTTPSPort: 443
        OriginProtocolPolicy: "https-only"
        OriginSslProtocols:
          Quantity: 3
          Items: [ "TLSv1", "TLSv1.1", "TLSv1.2" ]
        OriginReadTimeout: 30
        OriginKeepaliveTimeout: 5
    ]

  setViewerCertificate = async (name) ->
    cert = yield sky.acm.fetch name

    ACMCertificateArn: cert
    SSLSupportMethod: 'sni-only'
    MinimumProtocolVersion: sky.config.aws.cache.protocol
    Certificate: cert
    CertificateSource: 'acm'


  {buildOrigins, setViewerCertificate}
