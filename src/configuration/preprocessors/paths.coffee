{cat, empty} = require "fairmont"

module.exports = (description) ->
  {resources} = description

  # Remove any querystring data from the URI template so that we can feed the path template into Gateway when declaring a resource.
  # TODO: Support more of the RFC URI templating spec and use more sophisticated parsing to convert from that to a form supported by Gateway.
  extractPath = (resource) ->
    matchIndex = resource.uriTemplate.indexOf "{?"
    if matchIndex < 0
      resource.uriTemplate
    else
      resource.uriTemplate.slice 0, matchIndex

  for k, v of resources
    resources[k].path = extractPath v
  description.resources = resources
  description
