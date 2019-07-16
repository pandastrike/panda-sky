import {flow} from "panda-garden"
import {first} from "panda-parchment"

within = (collection, example) -> example in collection
without = (collection, example) -> example not in collection

# Infer request-response signature from the API configuration.
expandSignature = (method) ->
  {signatures:{request, response}} = method
  {status} = response

  if request.schema && !request.mediatype
    request.mediatype = ["application/json"]

  if !response.mediatype && (within [200, 201], first status)
    response.mediatype = ["application/json"]

  status.push 304 if response.cache && (without status, 304)
  status.push 400 if (without status, 400)
  status.push 406 if response.mediatype && (without status, 406)
  status.push 415 if request.mediatype && (without status, 415)
  status.push 500 if (without status, 500)

expandSignatures = (config) ->

  for r, resource of config.resources
    for httpMethod, method of resource.methods
      expandSignature method

  config

expandResources = (config) ->

  for name, resource of config.resources
    config.resources[name].name = name

  config

expand = flow [
  expandResources
  expandSignatures
]

export default expand
