{async, cat} = require "fairmont"

module.exports = (cfr, config) ->
  _list = async (current=[], marker) ->
    params = MaxItems: 100
    params.Marker = marker if marker
    data = yield cfr.listDistributions params
    current = cat current, data.DistributionList.Items
    if data.IsTruncated
      _list current, data.DistributionList.Marker
    else
      current

  _create = async (name) ->
    yield cfr.createDistribution DistributionConfig: yield config.build name

  _update = async ({Id, ETag, DistributionConfig}) ->
    params =
      Id: Id
      IfMatch: ETag
      DistributionConfig: DistributionConfig
    yield cfr.updateDistribution params

  _disable = async (Distribution) ->
    Distribution.DistributionConfig.Enabled = false
    yield _update Distribution

  _delete = async ({Id, ETag}) ->
    params =
      Id: Id
      IfMatch: ETag
    yield cfr.deleteDistribution params

  _wait = async ({Id}) ->
    while true
      {Distribution: {Status}} = yield cfr.getDistribution {Id}
      if Status == "Deployed" then return else yield sleep 15000

  {_create, _delete, _disable, _list, _update, _wait}
