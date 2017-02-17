{toLower, capitalize, first} = require "fairmont"

# Cycle through the actions on every resource and generate their algorithmic
# names.  This includes CFo template names (CamelName) as well as lambda
# defintion names (dash-name).  These names are attached to the resource actions
# as implict properties and applied in the templates.
module.exports = (description) ->
  {resources} = description

  makeCamelName = (resource, action) ->
    out = capitalize toLower resource
    out += capitalize toLower action.method
    if action.signature?.request
      out += capitalize toLower action.signature.request
    else if action.signature?.response
      out += capitalize toLower action.signature.response
    out

  makeDashName = (resource, method) ->
    out = toLower resource
    out += "-"
    out += toLower action.method
    if action.signature?.request
      out += "-"
      out += toLower action.signature.request
    else if action.signature?.response
      out += "-"
      out += toLower action.signature.response
    out

  hasDependency = (signature) ->
    if signature.request || signature.response then true else false

  for r, resource of resources
    for a, action of resource.actions
      resources[r]["actions"][a].camelName = makeCamelName r, action
      resources[r]["actions"][a].dashName = makeDashName r, action
      resources[r]["actions"][a]["signature"].dependent = hasDependency action.signature
  description.resources = resources
  description
