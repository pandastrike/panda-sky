{toLower, camelCase, capitalize, first, last, values, project, collect, cat} = require "fairmont"

# Cycle through every resource and build up a dictionary of resources that is
# acceptable to Gateway.  In the case of nested resources or those with path
# parameters, each antecedeant must be present, even if not defined explictly.
# Implicit, "virtual" collections are added here.
module.exports = (description) ->
  {resources} = description
  counter = 0 # keeps resource names unique #TODO: Do better

  # Helper to add a virtual, antecedeant resource to the resources dictionary.
  # The method makes implicit resources from the user's API description explicit
  # for the purposes of the CloudFormation template.
  addVirtualResource = (p) ->
    key = "virtual#{counter}"
    counter++
    resources[key] =
      path: p
      description: "Implict resource created for template."
      actions: {}

  # Helper to recursively traverse a path to make sure a nested resources
  # antecedeants exist.  Add them if they do not.
  walkPath = (p) ->
    if p[0] not in paths
      paths.push p[0]
      addVirtualResource p[0]

    return if p.length == 1
    ante = [p[0], p[1]].join("/")
    p = if p.length > 2 then cat([ante], p[2...]) else [ante]
    walkPath p

  stripPath = (p) ->
    p = p[1...] if first(p) == "/"
    p = p.slice(0, -1) if last(p) == "/"
    p

  # Helper to return the key of a resource in the main dictionary given its url path.
  getKey = (path) ->
    for k, v of resources
      return k if v.path == path

    throw new Error "Failure in resource parsing"



  # Get an authoritative list of all paths.
  paths = collect project "path", values(resources)
  paths = (stripPath path for path in paths)

  # Remove path's leading and trailing slashes, if present.
  for r, resource of resources
    p = resource.path
    continue if p == "/"
    resources[r].path = stripPath p

  # Inspect path for implicit resources.
  for r, resource of resources
    continue if resource.path == "/"
    p = resource.path.split("/")
    continue if p.length == 1
    walkPath p

  # Iterate over the full resource dictionary and add computed fields.

  # Grants endpoint access to Lambda. Adds the path with glob characters replacing path parameters.
  for r, resource of resources
    p = resource.path.replace /\{.*\}/g, "*"
    if p == "/"
      resources[r].permissionsPath = "/"
    else
      resources[r].permissionsPath = "/#{p}"

  # Identify unique path and parents.
  for r, resource of resources
    p = resource.path
    parts = p.split "/"

    if p == "/"
      resources[r].parent = "/"
      resources[r].pathPart = "/"
    else
      resources[r].pathPart = last parts
      if parts.length == 1
        resources[r].parent = "/"
      else
        resources[r].parent = getKey( parts.slice(0,-1).join("/") )

  for name, resource of resources
    resource.name = capitalize name
    resource.gatewayResourceName = "#{capitalize(name)}Resource"
    resource.parentResourceName = "#{capitalize(resource.parent)}Resource"
    if resource.path == "/"
      resource.rootResource = true

  description.resources = resources
  description
