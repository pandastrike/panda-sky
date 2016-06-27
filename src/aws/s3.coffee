{async, sleep, read, md5} = require "fairmont"
{createReadStream} = require "fs"
{join} = require "path"
mime = require "mime"

module.exports = async (env) ->
  config = require("../configuration/publish")(env)
  {s3} = yield require("./index")(config.aws.region)


  # Create a new bucket if it does not exist.
  establish = async (name) ->
    try
      exists = yield s3.headBucket Bucket: name
    catch e
      switch e.statusCode
        when 301
          console.error "The bucket is in a different region than the client " +
            "is currently configured to target. Correct the region in your " +
            ".h9 file."
          throw new Error()
        when 403
          console.error "You are not authorized to modify this bucket."
          throw e
        when 404
          exists = false
        else
          throw e

    return true if exists

    # Create a new, empty S3 bucket.
    try
      yield s3.createBucket {Bucket: name}
      yield sleep 15000
    catch e
      console.error "Failed to establish bucket.", e
      throw new Error()

  # Upsert an object to the bucket.
  putObject = async (bucket, key, path) ->
    content =
      if "text" in mime.lookup(path)
        yield read path
      else
        yield read path, "buffer"

    params =
      Bucket: bucket
      Key: key
      ContentType: mime.lookup path
      ContentMD5: new Buffer(md5(content), "hex").toString('base64')
      Body: createReadStream path

    yield s3.putObject params

  # Return exposed functions.
  {establish, putObject}
