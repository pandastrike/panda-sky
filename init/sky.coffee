import AWS from "aws-sdk"
import YAML from "js-yaml"

# Access the Panda Sky helpers.
import sky from "panda-sky-helpers"
{env, dispatch, method, s3} = sky AWS

# You can use the S3 helper to get functions to access the App's datastore.
{get, put, del} = s3 "foobar"

# Handlers
import homeGet from "./home.get"

API = dispatch
  "#{env.fullName}-discovery-get": method (request, context) ->
    # Instantiate new s3 helper to target deployment "src" bucket.
    {get} = s3 "#{env.environment}-#{env.projectID}"
    YAML.safeLoad await get "api.yaml"

  "#{env.fullName}-greeting-get": method (request, context) ->
    name = request.url.path.name || "World"
    name = name.charAt(0).toUpperCase() + name.slice(1)
    "Hello, #{name}!"

  "#{env.fullName}-home-get": method homeGet

export {API}
