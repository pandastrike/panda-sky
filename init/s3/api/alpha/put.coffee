import SDK from "aws-sdk"

# Access the Panda Sky helpers.
import {env, aws, response} from "panda-sky-helpers"
{NotFound} = response
{S3} = aws SDK

# Instantiate new s3 helper to target deployment "alpha" bucket.
bucketName = "sky-#{env.projectID}-alpha"
put = S3.put bucketName

handler = (request, context) ->
  console.log request
  if !await S3.bucketExists bucketName
    throw new NotFound "The Bucket #{bucketName} cannot be found."
  else
    {name} = request.url.path
    {fileContent} = request.content
    await put name, fileContent, "plain/text"

export default handler
