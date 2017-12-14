import AWS from "aws-sdk"
import YAML from "js-yaml"

# Access the Panda Sky helpers.
import sky from "panda-sky-helpers"
{env, AWS:{S3}} = sky AWS

# Instantiate new s3 helper to target deployment "src" bucket.
bucketName = "sky-#{env.projectID}-alpha"

dateTime = ->
  d = new Date()
  p = (value) -> if value < 10 then "0#{value}" else value

  "UTC #{d.getUTCFullYear()}-#{p(d.getUTCMonth() + 1)}-#{p d.getUTCDate()}" +
  " #{p d.getUTCHours()}:#{p d.getUTCMinutes()}:#{p d.getUTCSeconds()}"

handler = (request, context) ->
  if !await S3.bucketExists bucketName
    "The Bucket #{bucketName} cannot be found."
  else
    file = await S3.get bucketName, "record.yaml"
    file = if !file then {} else YAML.safeLoad file

    if file.writes
      file.writes.push dateTime()
    else
      file.writes = [dateTime()]

    if file.writeCount
      file.writeCount++
    else
      file.writeCount = 1

    await S3.put bucketName, "record.yaml", YAML.safeDump(file), "text/yaml"
    "Records updated."


export default handler
