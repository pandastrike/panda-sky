{async} = require "fairmont"
YAML = require "js-yaml"

# See wiki for more details. Configuration with context injection is roadmapped
# for Beta-02
name = "sky"
env = "staging"
projectID = "{{projectID}}"
app = "#{name}-#{env}"

# helper to simplify the S3 interface. Formal integration is roadmapped.
{get, set} = require("./s3")(app + "-" + projectID)

# Handlers
API =
  "#{app}-discovery-get": async (data, context, callback) ->
    # Instantiate new s3 helper to target deployment "src" bucket.
    {get} = require("./s3")("#{env}-#{projectID}")
    description = YAML.safeLoad yield get "api.yaml"
    callback null, description

  "#{app}-greeting-get": async (data, context, callback) ->
    {name} = data
    if !name then name = "World"
    message = "<h1>Hello, #{name}!</h1>"
    message +="<p>Seeing this page indicates a successful deployment of your test API with Panda Sky!</p>"
    callback null, message

exports.handler = (event, context, callback) ->
  try
    API[context.functionName] event, context, callback
  catch e
    callback e
