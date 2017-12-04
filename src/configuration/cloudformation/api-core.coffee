# This assembles the CloudFormation Description for core features of a Panda
# Sky deployment, the API Gateway and Lambdas that back it.

# Libraries
{resolve, parse} = require "path"
{async, merge, ls, read} = require "fairmont"
{yaml} = require "panda-serialize"

# Helper Classes
API = require "../../api"
Templater = require "../../templater"
preprocessors = require "../preprocessors"

# Paths
skyRoot = resolve __dirname, "..", "..", ".."
tPath = (file) -> resolve skyRoot, "templates", file

registerAPIComponentTemplates = async (T) ->
  components = yield ls tPath "api-components"
  for c in components when parse(c).ext == ".yaml"
    T.registerPartial(parse(c).name, yield read c)

getAPIDescription = async (root, globals) ->
  try
    api = yield API.read resolve root, "api.yaml"
    yield preprocessors.api merge api, globals
  catch e
    console.error "Unable to read API description."
    console.error e
    process.exit()

renderAPI = async (root, globals) ->
  config = yield getAPIDescription root, globals
  templater = yield Templater.read (tPath "api.yaml"), (tPath "api.schema.yaml")
  yield registerAPIComponentTemplates templater

  config.skyResources = config.resources
  yaml templater.render config


module.exports = {renderAPI}
