# Accept an integration response configuration object and the the API definition
# for a given HTTP method.  Use the mediatype(s) specified in the response
# signature to shape the response returned by Gateway.  That includes templates
# in the integration response (step 3) as well as JSON schema enforcement via the method resposne (step 4).

# TODO: For now, we just support JSON and HTML, but this is going to become quite sophisticated as we start using HTTP fully.
# ==============================================================================
# ==============================================================================
import {empty, keys} from "panda-parchment"

# Lookup the velocity template to use based on the mediatype given.
velocityTemplates =
  "application/json": """$input.json('$.data')"""
  "text/html": """$input.path('$.data')"""


Types = (integration, method) ->
  mediatype = method.signatures.response?.mediatype
  return integration unless mediatype

  templates = {}
  for type in mediatype
    if type in keys velocityTemplates
      templates[type] = velocityTemplates[type]
    else
      throw new Error "media type #{type} does not have a supported velocity
        template to map the lambda result to an HTTP response."

  unless empty templates
    integration.ResponseTemplates = templates

  integration

export default Types
