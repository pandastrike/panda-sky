# This helper makes it easier to manipulate data in S3.  It takes a bucket name
# and returns an interface that lets you put, get, or delete an object.
{merge} = require "fairmont"

module.exports = (AWS) ->
  s3 = new AWS.S3
  (bucketName) ->
    get = (key) ->
      new Promise (resolve, reject) ->
        s3.getObject
          Bucket: bucketName
          Key: key
          (error, data) ->
            unless error?
              resolve data.Body
            else
              reject error

    del = (key) ->
      new Promise (resolve, reject) ->
        s3.deleteObject
          Bucket: bucketName
          Key: key
          (error, data) ->
            unless error?
              resolve null
            else
              reject error

    put = (key, value, options={}) ->
      new Promise (resolve, reject) ->
        basic =
          Bucket: bucketName
          Key: key
          Body: value

        s3.putObject merge(basic, options),
          (error, data) ->
            unless error?
              resolve null
            else
              reject error

    {get, put, del}
