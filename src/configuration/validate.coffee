import {resolve} from "path"
import {flow} from "panda-garden"
import {merge, toJSON} from "panda-parchment"
import {exists, read as _read} from "panda-quill"
import {yaml} from "panda-serialize"
import AJV from "ajv"

ajv = new AJV()

readSchema = (parts...) ->
  yaml await _read resolve __dirname,
    "..", "..", "..", "..", "schema", parts...

startConfig = (root, env, profile="default") ->
  console.log "reading configuration..."
  {root, env, profile}

readAPI = (config) ->
  path = resolve config.root, "api.yaml"
  throw new Error "Cannot find api.yaml" unless exists path
  api = yaml await _read path

  schema = await readSchema "api", "description.yaml"
  schema.definitions = await readSchema "api", "definitions.yaml"

  unless ajv.validate schema, api
    console.error toJSON ajv.errors, true
    throw new Error "invalid Panda api.yaml configuration"

  merge config, api, {api}

readSky = (config) ->
  path = resolve config.root, "sky.yaml"
  throw new Error "cannot find sky.yaml" unless exists path
  sky = yaml await _read path

  schema = await readSchema "sky", "description.yaml"
  schema.definitions = await readSchema "sky", "definitions.yaml"

  unless ajv.validate schema, sky
    console.error toJSON ajv.errors, true
    throw new Error "invalid sky.yaml configuration"

  merge config, sky

validate = flow [
  startConfig
  readAPI
  readSky
]

export default validate
export {startConfig, readAPI, readSky}
