{join, resolve} = require "path"

#JSCK = require "jsck"
{call, read, empty} = require "fairmont"
{yaml} = require "panda-serialize"

module.exports = call ->
  try
    # schema = yaml.safeLoad readFileSync resolve join(__dirname, "..", "..",
    #   "configuration-schema", "main.yaml")
    # schema.definitions = yaml.safeLoad readFileSync resolve join(__dirname,
    #   "..", "..", "configuration-schema", "definitions.yaml")
    #
    # jsck = new JSCK.draft4 schema
    config = yaml yield read resolve join( process.cwd(), "mango.yaml")
    # {errors} = jsck.validate config
  catch e
    console.error "There was a problem validating this repo's configuration.", e
    throw new Error()

  # if !empty errors
  #   console.error "There is a problem with this repo's configurtion. Aborting."
  #   console.error errors
  #   throw new Error()

  config
