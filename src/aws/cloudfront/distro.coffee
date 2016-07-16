{async, collect, where, empty, sleep, deepEqual, merge} = require "fairmont"

module.exports = async (config, env) ->
  {cfr} = yield require("../index")(config.aws.region)
  distroConfig = yield require("./config")(config, env)
  {regularlyQualify} = do require "../url"

  # Create a new CFr distro for the deployment.
  create = async ->
    console.log "Creating CloudFront Distribution.  This will take 15-30 minutes."
    yield cfr.createDistribution { DistributionConfig: yield distroConfig.build() }


  # Delete the deployment's CFr distro and wait for it to disappear from your list.
  destroy = async ({Distribution}) ->
    yield cfr.deleteDistribution Id: Distribution.Id
    while true
      list = yield cfr.listDistributions().DistributionList.Items
      result = collect where {Id: Distribution.Id}, list
      if empty result then return true else yield sleep 15000



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
  update = async ({ETag, Distribution}) ->
    if !distroConfig.compare Distribution.DistributionConfig, yield distroConfig.build()
      console.log "Updating CloudFront Distribution.  This will take 15-30 minutes."
      params =
        Id: Distribution.Id
        IfMatch: ETag
        DistributionConfig:
          distroConfig.deepMerge Distribution.DistributionConfig, (yield distroConfig.build())

      yield cfr.updateDistribution params
    else
      console.log "CloudFront distribution is up-to-date."
      {ETag, Distribution}


  {fetch, create, sync, update, destroy}
