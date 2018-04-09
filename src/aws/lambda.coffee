{async} = require "fairmont"

module.exports = async (config) ->
  {lambda} = yield require("./index")(config.aws.region, config.profile)

  update = async (name, bucket, key) ->
    yield lambda.updateFunctionCode
      FunctionName: name
      Publish: true
      S3Bucket: bucket
      S3Key: key

  {update}
