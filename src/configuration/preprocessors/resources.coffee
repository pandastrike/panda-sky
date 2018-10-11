import {toLower, camelCase, capitalize, first, last, values, project, collect, cat} from "panda-parchment"

# Cycle through every resource and build up a dictionary of resources that is
# acceptable to Gateway.  In the case of nested resources or those with path
# parameters, each antecedeant must be present, even if not defined explictly.
# Implicit, "virtual" collections are added here.
Resources = (config) ->
  {resources} = config
  counter = 0 # keeps resource names unique #TODO: Do better

  # Helper to add a virtual, antecedeant resource to the resources dictionary.
  # The method makes implicit resources from the user's API description
  # explicit for the purposes of the CloudFormation template.
  addVirtualResource = (p) ->
    key = "virtual#{counter}"
    counter++
    resources[key] =
      path: p
      description: "Implict resource created for template."
      methods: {}

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

  # Helper to return the key of a resource in the main dictionary given its url
  # path.
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

  # Grants endpoint access to Lambda. Adds the path with glob characters
  # replacing path parameters.
  for r, resource of resources
    p = resource.path.replace /\{.*\}/g, "*"
    if p == "/"
      resources[r].permissionsPath = "/"
    else
      resources[r].permissionsPath = "/#{p}"

  # Identify unique path and parents.
  index = 1
  for r, resource of resources
    p = resource.path
    parts = p.split "/"

    if p == "/"
      resource.index = 0
      resource.parent = "/"
      resource.pathPart = "/"
    else
      resource.index = index
      index++
      resource.pathPart = last parts
      if parts.length == 1
        resource.parent = "/"
      else
        resource.parent = getKey( parts.slice(0,-1).join("/") )

    if resource.parent == "/"
      resource.parentID = '"Ref": "RootResourceId"'
    else
      resource.parentID = "Ref: #{capitalize resource.parent}Resource"


  for name, resource of resources
    resource.name = capitalize name
    resource.gateway =
      name:
        "#{capitalize(name)}Resource"
    resource.gatewayResourceName = "#{capitalize(name)}Resource"
    resource.parentResourceName = "#{capitalize(resource.parent)}Resource"
    if resource.path == "/"
      # We'll remove this resource from the main dictionary at the end of
      # processing, because we need to handle it separately in the
      # CloudFormation template
      config.rootResource = resource
      config.rootResourceKey = name
      resource.gateway.resourceID = '"Fn::GetAtt": ["API", "RootResourceId"]'
    else
      resource.gateway.resourceID = "Ref: #{resource.gateway.name}"

  config.resources = resources
  config

export default Resources
