import {resolve} from "path"
import {read} from "panda-quill"
import {keys} from "panda-parchment"
import {yaml} from "panda-serialize"
import JSCK from "jsck"

schemaPath = (name) ->
  resolve __dirname, "..", "..", "..", "..", "schema", "sky", name

getSchema = ->
  schema = yaml await read  schemaPath "description.yaml"
  schema.definitions = yaml await read schemaPath "definitions.yaml"
  schema

getConfig = (appRoot) -> yaml await read resolve appRoot, "sky.yaml"

fail = (errors) ->
  console.error errors
  console.error """
  ERROR: The configuration in sky.yaml has a problem.  Please correct
    before continuing.

    This operation will now discontinue.
  """
  console.log "Done."
  process.exit()

# Confirm the environment selected by the developer is present in configuration.
checkEnv = (env, config) ->
  available = keys config.aws.environments
  if env && env not in available
    msg = """
    WARNING: The provided environment, "#{env}", is not present in your sky.yaml
      configuration.  The available environments are:
    """
    msg += "\n=========================="
    msg += "\n    #{e}" for e in available
    msg += "\n=========================="
    msg += """
      \n\nPlease select from those or configure your desired environment.
      Done.
    """
    console.error msg
    process.exit()

Sky =
  read: (appRoot, env) ->
    jsck = new JSCK.draft4 await getSchema()
    config = await getConfig appRoot
    {valid, errors} = jsck.validate config
    fail errors if !valid
    checkEnv env, config
    config

export default Sky
