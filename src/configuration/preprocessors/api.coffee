{cat, empty} = require "fairmont"

module.exports = (description) ->
  {resources} = description
  # merge query params and path params into a single list
  extractQuery = (resource) ->
    if resource.query
      for parameter in resource.query
        name: parameter
        query: true
    else
      []

  extractPath = (resource) ->
    parameters = []
    re = /\{([^}]+)\}/g
    parameters.push m[1] while m = re.exec resource.path

    if !empty parameters
      for parameter in parameters
        name: parameter
        path: true
    else
      []

  for k, v of resources
    resources[k].parameters = cat (extractQuery v), (extractPath v)
  description.resources = resources
  description
