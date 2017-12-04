# Part of the Sky Resource Stack is the ability to deploy a custom domain for
# your API.  That consists of a CloudFront distribution along with its
# corresponding DNS records and Amazon Certificate Manager(ACM)-based TLS
# certificate.  This sub-module corrdinates their deployment, tear-down, and
# record-keeping within the Sky orchestration bucket.

#Destroy = require "./delete"
#Invalidate = require "./invalidate"
Publish = require "./publish"
Destroy = require "./delete"
Invalidate = require "./invalidate"

module.exports = (s) ->
  {prePublish, publish} = Publish s
  {preInvalidate, invalidate} = Invalidate s
  {preDelete, destroy} = Destroy s

  {
    delete: destroy
    preDelete
    preInvalidate
    invalidate
    prePublish
    publish
  }
