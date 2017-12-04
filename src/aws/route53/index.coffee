{async} = require "fairmont"

AWS = require "../index"
Helpers = require "./primatives"

module.exports = async (sky) ->
  {route53} = yield AWS sky.config.aws.region
  {_delete, _get, _getHostedZoneID, _listRecords, _needsUpdate
   _upsert, _wait} = Helpers route53

  # Create or update the DNS record.
  publish = async (name, target) ->
    record = yield _get name
    if !record || yield _needsUpdate record, target
      id = yield _upsert name, target
      yield _wait id

  # Delete the DNS record if it exists and is what we expect.
  destroy = async (name, target) ->
    # Check for hosted zone.  We don't require in pre-delete check.
    skip = -> console.error """
      WARNING: No DNS record found for #{name}. Skipping deletion.
    """

    return skip() if !yield _getHostedZoneID name
    record = yield _get name
    return skip() if !record
    return skip() if !yield _needsUpdate record, target

    id = yield _delete name, target
    yield _wait id


  {
    delete: destroy
    get: _get
    getHostedZoneID: _getHostedZoneID
    publish
  }
