{async} = require "fairmont"
YAML = require "js-yaml"

# App name with its environment, context injection is roadmapped for beta-02
name = "sky-staging"

# helper to simplify the S3 interface. Formal integration is roadmapped.
{get, set} = require("./s3")(name);

# Handlers
API =
  "#{name}-get-description": async (data, context, callback) ->
    # Instantiate new s3 helper to target deployment "src" bucket.
    {get} = require("./s3")("#{name}-src");
    description = YAML.safeLoad yield get "api.yaml"
    callback null, description

exports.handler = (event, context, callback) ->
  try
    API[context.functionName] event, context, callback
  catch e
    callback e
