{async} = require "fairmont"
extractParamters = require "./parameters"
extractCFr = require "./cfr"
extractS3 = require "../s3"

module.exports = async (description) ->
  # Extract path and querystring parameter configuration
  description = extractParamters description

  # Extract CloudFront configuration
  description = yield extractCFr description

  # TODO: Remove this in favor of the S3 mixin, once that model is refined for
  # Beta-02
  description.aws.buckets = yield extractS3(description).buckets

  description
