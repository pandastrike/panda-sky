{async} = require "fairmont"

scan = require "./scan"
Confirm = require "./confirm"

module.exports = (s) ->
  {isViable} = scan s
  confirm = Confirm s

  # All of the stuff needed before we're sure it's safe to proceed.
  preDelete = async (name, options) ->
    console.error "-- Scanning AWS for appropriate Cloud resources."
    yield isViable name
    yield confirm name, options

  # This is the main domain deletion engine.
  destroy = async (name) ->
    # Delete the CloudFront distribution
    console.error "-- Issuing edge cache tear-down..."
    {DomainName} = yield s.cfr.delete name

    # Delete the corresponding DNS records.
    console.error "-- Issuing DNS record removal..."
    yield s.route53.delete name, DomainName if DomainName

    # Remove this hostname to the environment's Sky Bucket.
    yield s.meta.hostnames.remove name

  {preDelete, destroy}
