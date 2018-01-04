{resolve} = require "path"
{async, read, keys} = require "fairmont"
{yaml} = require "panda-serialize"
JSCK = require "jsck"

schemaPath = (name) ->
  resolve __dirname, "..", "..", "schema", "sky", name

getSchema = async ->
  schema = yaml yield read  schemaPath "description.yaml"
  schema.definitions = yaml yield read schemaPath "definitions.yaml"
  schema

getConfig = async (appRoot) -> yaml yield read resolve appRoot, "sky.yaml"

fail = (errors) ->
  console.error errors
  console.error """
  ERROR: The configuration in sky.yaml has a problem.  Please correct
    before continuing.

    This operation will now discontinue.
    Done.
  """
  process.exit()

# Confirm the environment selected by the developer is present in configuration.
checkEnv = (env, config) ->
  available = keys config.aws.environments
  if env not in available
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

module.exports =
  read: async (appRoot, env) ->
    jsck = new JSCK.draft4 yield getSchema()
    config = yield getConfig appRoot
    {valid, errors} = jsck.validate config
    fail errors if !valid
    checkEnv env, config
    config
