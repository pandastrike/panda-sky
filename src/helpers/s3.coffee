{promise} = require "fairmont"
AWS = require "aws-sdk"
s3 = new AWS.S3

module.exports = (bucketName) ->
  get = (key) ->
    promise (resolve, reject) ->
      s3.getObject
        Bucket: bucketName
        Key: key
        (error, data) ->
          unless error?
            resolve data.Body
          else
            reject error

  put = (key, value) ->
    promise (resolve, reject) ->
      s3.putObject
        Bucket: bucketName
        Key: key
        Body: value
        (error, data) ->
          unless error?
            resolve null
          else
            reject error

  {get, put}
