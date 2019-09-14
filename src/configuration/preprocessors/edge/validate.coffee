import {resolve} from "path"
import {toJSON} from "panda-parchment"
import {exists, read} from "panda-quill"
import {yaml} from "panda-serialize"
import AJV from "ajv"

ajv = new AJV()

readSchema = (parts...) ->
  yaml await read resolve __dirname,
    "..", "..", "..", "..", "..", "..", "schema", parts...

validate = (config, type) ->
  path = resolve config.root, "edges", type, "sky.yaml"
  throw new Error "cannot find #{path}" unless await exists path
  edgeConfig = yaml await read path

  schema = await readSchema "edges", "description.yaml"
  schema.definitions = await readSchema "edges", "definitions.yaml"

  unless ajv.validate schema, edgeConfig
    console.error toJSON ajv.errors, true
    throw new Error "invalid edge configuration"

  edge = edgeConfig.environments[config.env]
  edge.type = type
  config.environment.edge = edge
  config

export default validate
