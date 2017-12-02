{async, cat, collect, where, empty} = require "fairmont"
{root, fullyQualify} = require "../url"

module.exports = (route53) ->

  _listHZ = async (current=[], marker) ->
    params = MaxItems: 100
    params.Marker = marker if marker
    data = yield route53.listHostedZones params
    current = cat current, data.HostedZones
    if data.IsTruncated
      yield _listHZ current, data.Marker
    else
      current

  _listRecords = async (id, current=[], marker) ->
    params =
      HostedZoneId: id
      MaxItems: 100
    params.StartRecordName = marker if marker
    data = yield route53.listResourceRecordSets params
    current = cat current, data.ResourceRecordSets
    if data.IsTruncated
      yield _listRecords id, current, data.NextRecordName
    else
      current

  _getHostedZoneID = async (name) ->
    zone = root name
    zones = yield _listHZ()
    result = collect where {Name: zone}, zones
    if empty result then false else result[0].Id

  _target = (target) ->
    HostedZoneId: "Z2FDTNDATAQYW2" # HostedZoneId for cloudfront.net
    DNSName: fullyQualify target
    EvaluateTargetHealth: false

  _changeRecords = async (name, Changes) ->
    params =
      HostedZoneId: yield _getHostedZoneID name
      ChangeBatch: {Changes}
    {ChangeInfo: {Id}} = yield route53.changeResourceRecordSets params
    Id

  _changes = (action, name, target) ->
    Action: action,
    ResourceRecordSet:
      Name: fullyQualify name
      Type: "A"
      AliasTarget: _target target

  _upsert = async (name, target) ->
    changes = [ _changes "UPSERT", name, target ]
    yield _changeRecords name, changes

  _delete = async (name, target) ->
    changes = [ _changes "DELETE", name, target ]
    yield _changeRecords name, changes

  _wait = async (Id) ->
    while true
      {ChangeInfo: {Status}} = yield route53.getChange {Id}
      if Status == "INSYNC" then return else yield sleep 10000


  {_delete, _getHostedZoneID, _listHZ, _listRecords, _target, _upsert, _wait}
