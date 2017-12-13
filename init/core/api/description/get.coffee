import AWS from "aws-sdk"
import YAML from "js-yaml"

# Access the Panda Sky helpers.
import sky from "panda-sky-helpers"
{env, s3} = sky AWS

handler = (request, context) ->
  # Instantiate new s3 helper to target deployment "src" bucket.
  {get} = s3 "#{env.fullName}-#{env.projectID}"
  YAML.safeLoad await get "api.yaml"

export default handler
