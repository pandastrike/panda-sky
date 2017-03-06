{toLower, capitalize, first, toUpper} = require "fairmont"

# Cycle through the actions on every resource and generate their algorithmic
# names.  This includes CFo template names (CamelName) as well as lambda
# defintion names (dash-name).  These names are attached to the resource actions
# as implict properties and applied in the templates.
module.exports = (description) ->
  {resources} = description

  makeCamelName = (resource, action) ->
    out = capitalize toLower resource
    out += capitalize toLower action.method
    out

  makeDashName = (resource, method) ->
    out = toLower resource
    out += "-"
    out += toLower action.method
    out

  hasDependency = (signature) ->
    if signature.request || signature.response then true else false

  for r, resource of resources
    methods = ["options"]
    for a, action of resource.actions
      methods.push action.method
      resources[r]["actions"][a].camelName = makeCamelName r, action
      resources[r]["actions"][a].dashName = makeDashName r, action
      resources[r]["actions"][a]["signature"].dependent = hasDependency action.signature

    resources[r].methodList = toUpper methods.join ", "

  description.resources = resources
  description
