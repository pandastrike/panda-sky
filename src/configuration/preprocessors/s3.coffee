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
        when 403
          true
        when 301
          console.warn "S3 bucket exists, but is in a Region other than specified in sky.yaml."
          console.warn "Panda Sky cannot move the bucket.  Please adjust manually and try again, or target the Region the bucket currently occupies."
        when 404
          false
        else
          throw e

  {buckets, tags} = description
  out = []
  out.push b for b in buckets when !(yield bucketExists b)
  out

  buckets:
    for bucket in out
      name: bucket
      resourceTitle: capitalize camelCase plainText bucket
      tags: tags
