# Part of the Sky Resource Stack is the ability to deploy a custom domain for
# your API.  That consists of a CloudFront distribution along with its
# corresponding DNS records and Amazon Certificate Manager(ACM)-based TLS
# certificate.  This sub-module corrdinates their deployment, tear-down, and
# record-keeping within the Sky orchestration bucket.

destroy = require "./delete"
invalidate = require "./invalidate"
Publish = require "./publish"

module.exports = (s) ->
  {prePublish, publish} = publish s
  {preInvalidate, invalidate} = invalidate s
  {preDestroy, destroy} = destroy s

  {
    delete: destroy
    preDelete: preDestroy
    preInvalidate
    invalidate
    prePublish
    publish
  }
