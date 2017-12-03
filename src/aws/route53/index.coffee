{async, sleep, collect, where, empty, deepEqual} = require "fairmont"

AWS = require "../index"
Helpers = require "./primatives"

module.exports = async (sky) ->
  {route53} = yield AWS sky.config.aws.region
  {_delete, _getHostedZoneID, _listRecords, _target,
   _upsert, _wait} = Helpers route53

  # Determine if the user owns the requested URL as a public hosted zone
  getHostedZoneID = async (name) -> yield _getHostedZoneID name

  get = async (name) ->
    records = yield _listRecords yield getHostedZoneID name
    result = collect where {Name: name}, records
    if empty result then false else result[0]

  needsUpdate = ({Type, AliasTarget}, target) ->
    Type != "A" || !deepEqual AliasTarget, _target target

  # Create or update the DNS record.
  publish = async (name, target) ->
    record = yield get name
    if !record || yield needsUpdate record, target
      id = yield _upsert name, target
      yield _wait id

  # Delete the DNS record if it exists and is what we expect.
  destroy = async (name, target) ->
    if yield getHostedZoneID name && record = yield get name
      if !yield needsUpdate record, target
        id = yield _delete name, target
        yield _wait id
    else
      console.error "WARNING: No DNS record found for #{name}. Skipping."


  {delete: destroy, get, getHostedZoneID, publish}
