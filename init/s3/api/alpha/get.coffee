import AWS from "aws-sdk"
import YAML from "js-yaml"

# Access the Panda Sky helpers.
import sky from "panda-sky-helpers"
{env, AWS:{S3}} = sky AWS

# Instantiate new s3 helper to target deployment "src" bucket.
bucketName = "sky-#{env.projectID}-alpha"
get = S3.get bucketName

handler = (request, context) ->
  if !await S3.bucketExists bucketName
    "The Bucket #{bucketName} cannot be found."
  else
    file = await get "record.yaml"
    if !file
      "There are no records to fetch."
    else
      YAML.safeLoad file

export default handler
