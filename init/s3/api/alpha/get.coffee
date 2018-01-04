import AWS from "aws-sdk"
import YAML from "js-yaml"

# Access the Panda Sky helpers.
import sky from "panda-sky-helpers"
{env, AWS:{S3}, response:{NotFound}} = sky AWS

# Instantiate new s3 helper to target deployment "alpha" bucket.
bucketName = "sky-#{env.projectID}-alpha"
get = S3.get bucketName

handler = (request, context) ->
  if !await S3.bucketExists bucketName
    throw new NotFound "The Bucket #{bucketName} cannot be found."
  else
    {name} = request.url.path
    file = await get name
    throw new NotFound() if !file
    YAML.safeLoad file

export default handler
