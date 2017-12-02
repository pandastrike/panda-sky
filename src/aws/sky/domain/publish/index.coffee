{async} = require "fairmont"

scan = require "./scan"
Confirm = require "./confirm"
Rollover = require "./rollover"

module.exports = (s) ->
  {isViable} = scan s
  confirm = Confirm s
  {rollover, needsRollover} = Rollover s

  # All of the stuff needed before we're sure it's safe to proceed.
  prePublish = async ->
    console.error "-- Scanning AWS for appropriate Cloud resources."
    yield isViable()
    return yield rollover() if yield needsRollover()
    yield confirm()

  # This is the main domain publishing engine.
  publish = async ->
    # Deploy the CloudFront distribution
    console.error "-- Issuing edge cache deployment..."
    yield s.cfr.publish()

    # Update the corresponding DNS records.
    console.error "-- Issuing DNS record update..."
    yield s.route53.publish()

  {prePublish, publish}
