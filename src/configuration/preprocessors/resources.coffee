import {first, last, value, cat, toLower, toUpper, plainText, dashed, camelCase, capitalize, values} from "panda-parchment"
import {collect, project} from "panda-river"

templateCase = (string) -> capitalize camelCase plainText string

# Cycle through every resource and build up a dictionary of resources that is
# acceptable to Gateway.  In the case of nested resources or those with path
# parameters, each antecedeant must be present, even if not defined explictly.
# Implicit, "virtual" collections are added here.
Resources = (config) ->
  {resources} = config
  counter = -1 # keeps resource names unique #TODO: Do better

  strip = (resource) ->
    p = resource.path
    return if p == "/"
    p = p.slice 1 if first(p) == "/"
    p = p.slice 0, -1 if last(p) == "/"

    resource.path = p

  # Helper to add a virtual, antecedeant resource to the resources dictionary.
  # The method makes implicit resources from the user's API description
  # explicit for the purposes of the CloudFormation template.
  addVirtualResource = (path) ->
    counter++
    resources["virtual#{counter}"] =
      path: path
      description: "Implict resource created for template."
      methods: {}

  # Helper to recursively traverse a path to make sure a nested resources
  # antecedeants exist.  Add them if they do not.
  _walk = (p) ->
    if p[0] not in paths
      paths.push p[0]
      addVirtualResource p[0]

    return if p.length == 1
    ante = [p[0], p[1]].join "/"
    p = if p.length > 2 then cat([ante], p[2...]) else [ante]
    _walk p

  walk = ({path}) ->
    return if path == "/"
    _walk path.split "/"

  # Lookup resource name given its path.
  getResourceName = (path) ->
    for name, resource of resources
      return name if resource.path == path

    throw new Error "Failure in resource parsing"


  #########################################################
  # Processing starts here

  # Remove path's leading and trailing slashes, if present.
  strip resource for _, resource of resources

  # Collect an authoritative list of all *real* resource paths.
  paths = collect project "path", values resources

  # Insert virtual resource paths for implicit Gateway resources.
  walk resource for _, resource of resources

  #####################
  # Iterate over the full resource dictionary and add computed fields.
  #####################

  # Grants endpoint access to Lambda. Adds the path with glob characters
  # replacing path parameters.
  for _, resource of resources
    p = resource.path.replace /\{.*?\}/g, "*"
    if p == "/"
      resource.permissionsPath = "/"
    else
      resource.permissionsPath = "/#{p}"

  # Identify unique path and parent resources. Also, here we assign an "index"
  # to resources. It is ugly as fuck, but it lets us reference a Gateway
  # resource when defining a Lambda across split templates. Root is 0, and
  # then we count up from there.
  index = 1
  for name, resource of resources
    parts = resource.path.split "/"
    resource.name = name
    resource.gateway = name: templateCase name

    if resource.path == "/"
      resource.index = 0
      resource.gateway.pathPart = "/"
      resource.gateway.parentID = '"Ref": "RootResourceId"'

      # Make note of this name for when we're done pre-processing.
      config._rootResourceName = name
    else
      resource.index = index
      index++
      resource.gateway.pathPart = last parts
      resource.gateway.resourceID = "Ref: #{resource.gateway.name}"
      resource.gateway.parentID =
        if parts.length == 1
          '"Ref": "RootResourceId"'
        else
          _name = getResourceName parts.slice(0,-1).join "/"
          "Ref: #{templateCase _name}Resource"

  config.resources = resources
  config

export default Resources
