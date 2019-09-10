import {resolve} from "path"
import {toJSON} from "panda-parchment"
import {exists, read} from "panda-quill"
import {yaml} from "panda-serialize"
import AJV from "ajv"

ajv = new AJV()

readSchema = (parts...) ->
  yaml await read resolve __dirname,
    "..", "..", "..", "..", "..", "..", "schema", parts...

validate = (config, name) ->
  path = resolve config.root, "workers", name, "sky.yaml"
  throw new Error "cannot find #{path}" unless await exists path
  workerConfig = yaml await read path

  schema = await readSchema "workers", "description.yaml"
  schema.definitions = await readSchema "workers", "definitions.yaml"

  unless ajv.validate schema, workerConfig
    console.error toJSON ajv.errors, true
    throw new Error "invalid worker configuration"

  worker = workerConfig.environments[config.env]
  worker.name = name
  config.environment.worker = worker
  config

export default validate
