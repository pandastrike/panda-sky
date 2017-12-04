{async} = require "fairmont"

scan = require "./scan"
Confirm = require "./confirm"
Rollover = require "./rollover"

module.exports = (s) ->
  {isViable} = scan s
  confirm = Confirm s
  {rollover, needsRollover} = Rollover s

  # All of the stuff needed before we're sure it's safe to proceed.
  prePublish = async (name, options) ->
    console.error "-- Scanning AWS for appropriate Cloud resources."
    yield isViable name
    return yield rollover name, options if yield needsRollover name
    yield confirm name, options

  # This is the main domain publishing engine.
  publish = async (name) ->
    # Deploy the CloudFront distribution
    console.error "-- Issuing edge cache deployment..."
    {DomainName} = yield s.cfr.publish name

    # Update the corresponding DNS records.
    console.error "-- Issuing DNS record update."
    yield s.route53.publish name, DomainName

    # Add this hostname to the environment's Sky Bucket.
    console.error "-- Updating Sky deployment records."
    yield s.meta.hostnames.add name

  {prePublish, publish}
