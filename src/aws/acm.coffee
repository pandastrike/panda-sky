{async, collect, where, empty} = require "fairmont"

module.exports = async (config) ->
  # TODO: Make the cert lookup more robust.  Consider how to handle multiple
  # region cert placement.
  {acm} = yield require("./index")("us-east-1")
  {root, regularlyQualify} = do require "./url"

  fetch = async (name) ->
    wild = (name) -> regularlyQualify "*." + root name

    try
      data = yield acm.listCertificates CertificateStatuses: [ "ISSUED" ]
      cert = collect where {DomainName: wild name}, data.CertificateSummaryList
    catch e
      console.error "Unexpected response while searching SSL certs.", e
      throw new Error()

    if empty cert
      console.error "You do not have an active certificate for", wild name
      throw new Error()
    else
      cert[0].CertificateArn

  {fetch}
