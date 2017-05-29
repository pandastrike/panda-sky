{async, sleep, read, md5} = require "fairmont"
{createReadStream} = require "fs"
{join} = require "path"
mime = require "mime"

module.exports = async (env, config, name) ->
  {s3} = yield require("./index")(config.aws.region)


  # Create a new bucket if it does not exist.
  establish = async ->
    try
      exists = yield s3.headBucket Bucket: name
    catch e
      switch e.statusCode
        when 301
          throw new Error "The bucket is in a different region than the client " +
            "is currently configured to target. Correct the region in your " +
            "sky.yaml file."
        when 403
          throw new Error "You are not authorized to modify this bucket."
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
      throw new "Failed to establish bucket. #{e}"

  # Upsert an object to the bucket.
  putObject = async (key, data, filetype) ->
    if filetype
      # data is stringified data.
      content = body = new Buffer data
    else
      # data is a path to file.
      filetype = mime.lookup data
      body = createReadStream data
      content =
        if "text" in mime.lookup(data)
          yield read data
        else
          yield read data, "buffer"

    params =
      Bucket: name
      Key: key
      ContentType: filetype
      ContentMD5: new Buffer(md5(content), "hex").toString('base64')
      Body: body

    yield s3.putObject params

  # Retrieve an S3 Object, or return false if it doesn't exist.
  getObject = async (key) ->
    params =
      Bucket: name
      Key: key

    try
      data = yield s3.getObject params
      data.Body.toString()
    catch e
      switch e.statusCode
        when 301
          throw new Error "The bucket is in a different region than the client " +
            "is currently configured to target. Correct the region in your " +
            "sky.yaml file."
        when 403
          throw new Error "You are not authorized to modify this S3 bucket: #{name}"
        when 404
          return false
        else
          throw new Error  "Unexpected reply from AWS: #{e}"

  deleteObject = async (key) ->
    params =
      Bucket: name
      Key: key
    try
      yield s3.deleteObject params
    catch e
      console.warn "Failed to delete #{key}", e

  destroy = async -> yield s3.deleteBucket Bucket: name


  # Return exposed functions.
  {destroy, deleteObject, establish, getObject, putObject}
