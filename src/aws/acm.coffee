{async, call, collect, where, empty} = require "fairmont"

module.exports = async ({profile}) ->
  # TODO: Consider how to handle multiple region cert placement.  For now, AWS
  #  has a preference for these certs to reside in us-east-1, so we should
  #  direct developers to always place their certs there.
  {acm} = yield require("./index")("us-east-1", profile)
  {root, regularlyQualify} = require "./url"

  wild = (name) -> regularlyQualify "*." + root name
  apex = (name) -> regularlyQualify root name

  getCertList = async ->
    data = yield acm.listCertificates CertificateStatuses: [ "ISSUED" ]
    data.CertificateSummaryList

  # Look for certs that contain wildcard permissions
  match = async (name, list) ->
    certs = collect where {DomainName: wild name}, list
    return certs[0].CertificateArn if !empty certs # Found what we need.

    # No primary wildcard cert.  Look for apex.
    certs = collect where {DomainName: apex name}, list
    for cert in certs
      data = yield acm.describeCertificate {CertificateArn: cert.CertificateArn}
      alternates = data.Certificate.SubjectAlternativeNames
      return cert.CertificateArn if wild(name) in alternates

    false # Failed to find wildcard cert among alternate names.

  fetch = async (name) ->
    try
      yield match name, yield getCertList()
    catch e
      console.error "Unexpected response while searching TLS certs."
      throw new Error()

  {fetch}
