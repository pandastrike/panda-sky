{async, sleep, read, md5} = require "fairmont"
{createReadStream} = require "fs"
mime = require "mime"

module.exports = async (env, config, name) ->
  # TODO: There's something funky about how S3's API handles the us-east-1 region.  It disallows the SDK to be pointed at the us-east-1 specific endpoint because it seems to use that as a default.  Anyway, it's weird and SunDog should do something to make this less painful.
  {region} = config.aws
  {s3} = yield require("./index")(region, config.profile)


  # Does the bucket exist?
  exists = async ->
    try
      yield s3.headBucket Bucket: name
      true
    catch e
      if e.statusCode == 404
        false
      else
        throw e

  # Create a new bucket if it does not exist.
  establish = async ->
    Policy = JSON.stringify
      Version: "2012-10-17"
      Statement: [
        Sid: "id-1"
        Effect: "Allow"
        Principal: "*"
        Action: "s3:GetObject"
        Resource: [
          "arn:aws:s3:::#{name}/templates/*"
        ]
      ]

    if yield exists()
      return true

    # Create a new, empty S3 bucket.
    console.error "Establishing new S3 bucket. One moment..."
    try
      yield s3.createBucket {Bucket: name}
      yield sleep 15000
    catch e
      console.error "Request ID", e.requestId
      throw new Error """
        Failed to establish bucket.
        Request ID: #{e.requestId}
        #{e}
      """

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
      if e.statusCode == 301
        console.error """
        The bucket is in a different region than the client is currently configured to target. Correct the region in your sky.yaml file.
        """
      throw e

  deleteObject = async (key) ->
    params =
      Bucket: name
      Key: key
    try
      yield s3.deleteObject params
    catch e
      console.warn "Failed to delete #{key}", e

  # Recursive method to grab all of the object headers in an S3 bucket
  listObjects = async (objects=[], marker) ->
    catList = (current, newContents) ->
      current.push obj.Key for obj in newContents
      current

    params =
      Bucket: name
      Delimiter: '#'
      MaxKeys: 1000

    params.Marker = marker if marker

    try
      data = yield s3.listObjects params
      if data.IsTruncated
        objects = catList objects, data.Contents
        yield listObjects objects, data.NextMarker
      else
        catList objects, data.Contents
    catch e
      console.warn "Failed to fetch list of objects from S3 bucket #{name}.", e

  destroy = async -> yield s3.deleteBucket Bucket: name

  # Return exposed functions.
  {destroy, deleteObject, establish, getObject, putObject, listObjects, exists}
