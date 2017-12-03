{async, collect, where, empty} = require "fairmont"
{regularlyQualify} = require "../url"
AWS = require "../index"
Config = require "./config"
Primatives = require "./primatives"

module.exports = async (sky) ->
  {env} = sky
  {cfr} = yield AWS sky.config.aws.region
  config = Config sky
  {_create, _delete, _disable, _extract, _invalidate,
    _list, _update, _wait} = Primatives cfr, config

  # Search the developer's current distributions for the target.
  get = async (name) ->
    list = yield _list()
    pattern =
      Aliases:
        Quantity: 1,
        Items: [ regularlyQualify name ]

    matches = collect where pattern, list
    if empty matches
      false
    else
      _extract yield cfr.getDistribution Id: matches[0].Id

  # CloudFront configurations are complex and filled with optional fields. To
  # determine if two are the same, we apply a build transformation on the
  # original. If the transformation result is identical, then no update.
  needsUpdate = async (name) ->
    {DistributionConfig: currentConfig} = yield get name
    newConfig = yield config.build name, Object.assign({}, currentConfig)
    !config.equal currentConfig, newConfig

  # Determine if create or update is needed.  Do that.
  publish = async (name) ->
    distro = yield get name
    if distro
      yield config.build name, distro.DistributionConfig
      yield _update distro
    else
      distro = yield _create name
    yield _wait distro
    distro

  # Disable and then delete the distribution.
  destroy = async (name) ->
    distro = yield get name
    if distro
      distro = yield _disable distro # Get new ETag after disabling
      yield _wait distro
      yield _delete distro
      distro
    else
      console.error "WARNING: #{name} distribution not found. Nothing to delete, moving on."

  # Invalidate the cache on this distribution.
  invalidate = async (name) ->
    distro = yield get name
    yield _invalidate distro



  {get, needsUpdate, publish, delete: destroy, invalidate}
