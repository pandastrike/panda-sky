# Accept an integration response configuration object and the the API definition
# for a given HTTP method.  Use the mediatype(s) specified in the response
# signature to shape the response returned by Gateway.  That includes templates
# in the integration response (step 3) as well as JSON schema enforcement via the method resposne (step 4).

# TODO: For now, we just support JSON and HTML, but this is going to become quite sophisticated as we start using HTTP fully.
# ==============================================================================
# ==============================================================================
import {empty, keys} from "panda-parchment"

# Lookup the velocity template to use based on the mediatype given.
velocity =
  "application/json": """$input.json('$')"""
  "text/html": """$input.path('$')"""

Types = (int, method) ->
  mt = method.signatures.response.mediatype
  if mt
    int.headers["Content-Type"] = "'#{mt.join(",")}'"

    templates = {}
    templates[k] = velocity[k] for k in mt when k in keys velocity
    int.ResponseTemplates = templates if !empty templates

  int

export default Types
