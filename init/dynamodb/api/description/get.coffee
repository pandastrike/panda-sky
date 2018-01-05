import SDK from "aws-sdk"
import YAML from "js-yaml"

# Access the Panda Sky helpers.
import {env, aws} from "panda-sky-helpers"
{S3} = aws SDK

# Instantiate new s3 helper to target deployment "src" bucket.
get = S3.get "#{env.fullName}-#{env.projectID}"

handler = (request, context) ->
  YAML.safeLoad await get "api.yaml"

export default handler
