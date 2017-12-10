# This assembles the CloudFormation Description for core features of a Panda
# Sky deployment, the API Gateway and Lambdas that back it.

# Libraries
{resolve, parse} = require "path"
{async, merge, ls, read} = require "fairmont"
{yaml} = require "panda-serialize"

# Helper Classes
Templater = require "../../templater"

# Paths
skyRoot = resolve __dirname, "..", "..", ".."
tPath = (file) -> resolve skyRoot, "templates", file

registerAPIComponentTemplates = async (T) ->
  components = yield ls tPath "api-components"
  for c in components when parse(c).ext == ".yaml"
    T.registerPartial(parse(c).name, yield read c)

renderAPI = async (config) ->
  templater = yield Templater.read (tPath "api.yaml"), (tPath "api.schema.yaml")
  yield registerAPIComponentTemplates templater

  config.skyResources = config.resources
  yaml templater.render config


module.exports = {renderAPI}
