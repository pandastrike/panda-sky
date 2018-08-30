# Part of the Sky Resource Stack is the ability to deploy a custom domain for
# your API.  That consists of a CloudFront distribution along with its
# corresponding DNS records and Amazon Certificate Manager(ACM)-based TLS
# certificate.  This sub-module corrdinates their deployment, tear-down, and
# record-keeping within the Sky orchestration bucket.
{async} = require "fairmont"

#Destroy = require "./delete"
#Invalidate = require "./invalidate"
Publish = require "./publish"
Destroy = require "./delete"
Invalidate = require "./invalidate"

module.exports = async (s) ->
  {prePublish, publish} = yield Publish s
  {preInvalidate, invalidate} = yield Invalidate s
  {preDelete, destroy} = yield Destroy s

  {
    delete: destroy
    preDelete
    preInvalidate
    invalidate
    prePublish
    publish
  }
