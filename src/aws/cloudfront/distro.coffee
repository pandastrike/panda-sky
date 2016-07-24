{async, collect, where, empty, sleep, deepEqual, merge} = require "fairmont"

module.exports = async (config, env) ->
  {cfr} = yield require("../index")(config.aws.region)
  distroConfig = yield require("./config")(config, env)
  {regularlyQualify} = do require "../url"

  # Create a new CFr distro for the deployment.
  create = async ->
    console.log "Creating CloudFront Distro.  This will take 15-30 minutes."
    yield cfr.createDistribution { DistributionConfig: yield distroConfig.build() }


  # Disable and delete the deployment's CFr distro.
  destroyDistro = async (distro) ->
    try
      d = yield update distro, true
      yield sync d
      yield cfr.deleteDistribution
        Id: d.Distribution.Id
        IfMatch: d.ETag
    catch e
      console.warn "WARNING: Did not delete CloudFront distribution."
      console.warn e.stack


  # Find the app's CFr distro, or return false.
  fetch = async ->
    list = (yield cfr.listDistributions {}).DistributionList.Items
    pattern =
      Aliases:
        Quantity: config.aws.hostnames.length
        Items: do -> regularlyQualify x for x in config.aws.hostnames

    matches = collect where pattern, list

    if empty matches
      false
    else
      yield cfr.getDistribution {Id: matches[0].Id}



  # Wait for a CFr distribution to be ready.
  sync = async (distro) ->
    while true
      data = yield cfr.getDistribution Id: distro.Distribution.Id
      return true if data.Distribution.Status == "Deployed"
      yield sleep 15000



  # If neccessary, update this deployment's CFr distro.
  update = async ({ETag, Distribution}, disabled) ->
    current = Distribution.DistributionConfig
    desired = yield distroConfig.build disabled
    if !(distroConfig.compare current, desired)
      if disabled
        console.log "Disabling CloudFront Distro. This will take 15-30 minutes."
      else
        console.log "Updating CloudFront Distro. This will take 15-30 minutes."
      params =
        Id: Distribution.Id
        IfMatch: ETag
        DistributionConfig: distroConfig.deepMerge current, desired

      yield cfr.updateDistribution params
    else
      console.log "CloudFront distribution is up-to-date."
      {ETag, Distribution}


  {fetch, create, sync, update, destroyDistro}
