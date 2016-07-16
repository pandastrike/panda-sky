{async, sleep, collect, where, empty, deepEqual} = require "fairmont"

module.exports = async (config) ->
  {route53} = yield require("./index")(config.aws.region)
  {root, fullyQualify} = do require "./url"


  # Determine if the user owns the requested URL as a public hosted zone
  getHostedZoneID = async ->
    zone = root config.aws.hostnames[0]
    zones = yield route53.listHostedZones {}
    result = collect where {Name: zone}, zones.HostedZones
    if empty result then false else result[0].Id

  # Adds an upsert event to the DNS batch changes.
  addUpsert = (source, target) ->
    Action: "UPSERT",
    ResourceRecordSet:
      Name: fullyQualify target
      Type: "A"
      AliasTarget:
        HostedZoneId: "Z2FDTNDATAQYW2" # HostedZoneId for cloudfront.net
        DNSName: fullyQualify source
        EvaluateTargetHealth: false

  # Adds a deletion event to the DNS batch changes.
  addDelete = (source, target) ->
    Action: "DELETE",
    ResourceRecordSet:
      Name: fullyQualify target
      Type: "A"
      AliasTarget:
        HostedZoneId: "Z2FDTNDATAQYW2" # HostedZoneId for cloudfront.net
        DNSName: fullyQualify source
        EvaluateTargetHealth: false

  # Scan this hosted zone and determine the changes for the requested records
  reconcileAdditions = (records, source) ->
    changeList = []
    for name in config.aws.hostnames
      record = collect where {Name: fullyQualify name}, records
      if !empty record
        # Escape if there's nothing to change.
        desired = addUpsert(source, name).ResourceRecordSet
        current = record[0]
        delete current.ResourceRecords
        continue if deepEqual desired, current
      # Add an update to the DNS changeList.
      changeList.push addUpsert source, name

    if empty changeList then false else changeList

  # Scan this hosted zone and find records that need to be deleted.
  reconcileDeletions = (records, source) ->
    changeList = []
    for name in config.aws.hostnames
      record = collect where {Name: fullyQualify name}, records
      changeList.push addDelete(source, name) if !empty record
    if empty changeList then false else changeList

  # Wait for DNS records to come into effect.
  sync = async (id) ->
    console.log "Waiting for DNS records to synchronize."
    while true
      data = yield route53.getChange {Id: id}
      if data.ChangeInfo.Status == "INSYNC"
        return true
      else
        yield sleep 5000

  # Implement the changes and wait for the batch to sync.
  implement = async (id, changes) ->
    params =
      HostedZoneId: id
      ChangeBatch: Changes: changes
    changeID = (yield route53.changeResourceRecordSets params).ChangeInfo.Id
    yield sync changeID

  # Point all hostnames to the CFr distribution. Build up
  set = async ({Distribution}) ->
    console.log "Setting DNS records."
    if id = yield getHostedZoneID()
      records = (yield route53.listResourceRecordSets {HostedZoneId: id}).ResourceRecordSets
      if changes = reconcileAdditions records, Distribution.DomainName
        yield implement id, changes
      console.log "DNS records up to date."
    else
      throw new Error "No Hosted Zone for #{root config.aws.hostnames[0]}."

  # Remove all DNS records of the hostnames, if they exist.
  destroy = async ({Distribution}) ->
    console.log "Deleting DNS records."
    if id = yield getHostedZoneID()
      records = (yield route53.listResourceRecordSets {HostedZoneId: id}).ResourceRecordSets
      if changes = reconcileDeletions records, Distribution.DomainName
        yield implement id, changes
      console.log "DNS records up to date."
    else
      console.warn "No Hosted Zone for #{root config.aws.hostnames[0]}."

  {set, destroy}
