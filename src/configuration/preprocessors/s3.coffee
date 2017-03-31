#===============================================================================
# Panda Sky Mixin: S3
# This mixin allocates the requested S3 buckets into your CFo stack. Buckets
# are retained after stack deletion, so here we scan for them in S3 before
# adding them to the new CFo template.
#===============================================================================
{async, plainText, camelCase, capitalize, empty} = require "fairmont"
module.exports = async (description) ->
  {s3} = yield require("../../aws")(description.region)

  bucketExists = async (name) ->
    try
      exists = yield s3.headBucket Bucket: name
      true
    catch e
      switch e.statusCode
        when 301, 403
          true
        when 404
          false
        else
          throw e

  {buckets} = description
  out = []
  out.push b for b in buckets when !(yield bucketExists b)
  out
  console.log out
  process.exit()

  buckets:
    for bucket in out
      name: bucket
      resourceTitle: capitalize camelCase plainText bucket
