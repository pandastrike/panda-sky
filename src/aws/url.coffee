# Helper functions to assist with url manipulation for AWS calls.
{last} = require "fairmont"

module.exports = ->
  # Enforces "fully qualified" form of hostnames and domains.  Idompotent.
  fullyQualify = (name) -> if last(name) == "." then name else name + "."

  # Named somewhat sarcastically.  Enforces "regular" form of hostnames
  # and domains that is more expected when navigating.  Idempotent.
  regularlyQualify = (name) -> if last(name) == "." then name[...-1] else name

  # Given an arbitrary URL, return the fully qualified root domain.
  # https://awesome.example.com/test/42#?=What+is+the+answer  =>  example.com.
  root = (url) ->
    try
      # Remove protocol (http, ftp, etc.), if present, and get domain
      domain = url.split('/')
      domain = if "://" in url then domain[2] else domain[0]

      # Remove port number, if present
      domain = domain.split(':')[0]

      # Now grab the root: the top-level-domain, plus the term to the left.
      terms = regularlyQualify(domain).split(".")
      terms = terms.slice(terms.length - 2)

      # Return the fully qualified version of the root
      fullyQualify terms.join(".")
    catch e
      console.error "Failed to parse root url", e
      throw new Error()

  {fullyQualify, regularlyQualify, root}
