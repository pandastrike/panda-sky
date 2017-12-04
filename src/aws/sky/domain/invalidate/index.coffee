{async} = require "fairmont"

scan = require "./scan"
Confirm = require "./confirm"

module.exports = (s) ->
  {isViable} = scan s
  confirm = Confirm s

  # All of the stuff needed before we're sure it's safe to proceed.
  preInvalidate = async (name, options) ->
    console.error "-- Scanning AWS for appropriate Cloud resources."
    yield isViable name
    yield confirm name, options

  invalidate = async (name) ->
    # Invalidate the CloudFront distribution's entire cache.
    console.error "-- Issuing edge cache invalidation..."
    yield s.cfr.invalidate name

  {preInvalidate, invalidate}
