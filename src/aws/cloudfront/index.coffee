{async, collect, where, empty} = require "fairmont"
{regularlyQualify} = require "../url"
AWS = require "../index"
Config = require "./config"

module.exports = async (env, config) ->
  {cfr} = yield AWS config.aws.region
  {makeConfig} = Config config.cache

  build = async (name) ->


  # Search the developer's current distributions for the target.
  get = async (name) ->
    list = (yield cfr.listDistributions {}).DistributionList.Items
    pattern =
      Aliases:
        Quantity: 1,
        Items: [ regularlyQualify name ]

    matches = collect where pattern, list
    if empty matches
      false
    else
      yield cfr.getDistribution Id: matches[0].Id

  create = async (name) ->
    params = DistributionConfig: yield makeConfig name
    yield cfr.createDistribution params

  update = async (ETag, Distribution) ->
    params =
      Id: Distribution.Id
      IfMatch: ETag
      DistributionConfig: Distribution.DistributionConfig
    yield cfr.updateDistribution params


    # Arrays need not be congruent, but merely a permutation of a given set.
    # This recursive helper smooths out arrays within nested objects so that we
    # can safely apply a deepEqual to compare current and new configurations.
    deepSort = (o) ->
      if Array.isArray o
        o.sort()
      else if typeof o == "object"
        n = {}
        n[k] = deepSort v for k,v of o
        n
      else
        o

    # Compare the current configuration we fetched from AWS to our desired end
    # state.  Because the configuration is complex and filled with optional fields,
    # we designate the desired configuration as a transformation on the current.
    # If this causes changes, then we need to issue a time consuming update.
    needsUpdate = async (name, {ETag, Distribution}) ->
      current = deepSort Distribution.DistributionConfig
      newconfig = deepSort yield makeConfig name, Object.assign({}, current)

      if deepEqual current, newconfig
        false
      else
        true
