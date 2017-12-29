import AWS from "aws-sdk"
import YAML from "js-yaml"

# Access the Panda Sky helpers.
import sky from "panda-sky-helpers"
{env, AWS:{S3}, response:{NotFound}} = sky AWS

# Instantiate new s3 helper to target deployment "alpha" bucket.
bucketName = "sky-#{env.projectID}-alpha"
del = S3.del bucketName

handler = (request, context) ->
  if !await S3.bucketExists bucketName
    throw new NotFound "The Bucket #{bucketName} cannot be found."
  else
    {name} = request.url.path
    await del name

export default handler
