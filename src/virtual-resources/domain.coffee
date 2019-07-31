import {join} from "path"
import {flow} from "panda-garden"
import {first} from "panda-parchment"
import Interview from "panda-interview"
import {yaml} from "panda-serialize"
import {s3} from "./bucket"
import {cloudformation} from "./stacks"

questions = (action, domain) ->
  switch action
    when "publish"
      [
        name: "continue"
        description: """
          This publishes a custom domain at:
              #{domain}
          Would you like to continue? [Y/n]
        """
        default: "n"
      ]
    when "teardown"
      [
        name: "continue"
        description: """
          This deletes the custom domain at:
              #{domain}
          This is a destructive operation.
          Would you like to continue? [Y/n]
        """
        default: "n"
      ]
    else
      throw new Error "unknown custom domain action"

prompt = (action) ->
  {ask} = new Interview()
  (config) ->
    domain = first config.environment.hostnames
    if answers = await ask questions action, domain
      config
    else
      throw new Error "aborting action"

establishLogBucket = (config) ->
  {bucketTouch} = config.sundog.S3()
  if {logBucket} = config.environment.cache.waf
    console.log "configuring WAF logging bucket..."
    await bucketTouch logBucket
  config

upsertDomain = (config) ->
  {upload} = s3 config
  {format, publish, read} = cloudformation config
  {templates, cache} = config.environment

  console.log "Custom Domain Deploy"
  await upload "custom-domain.yaml", templates.customDomain
  await publish format cache.stack, "custom-domain.yaml"
  console.log "Outputs:"
  console.log yaml await read cache.stack
  config

_teardownDomain = (config) ->
  {remove} = s3 config
  {teardown} = cloudformation config

  console.log "Custom Domain Teardown"
  await teardown config.environment.cache.stack
  await remove "custom-domain.yaml"
  config

invalidateDomain = (config) ->
  {invalidate, get} = config.sundog.CloudFront()
  console.log "Edge Cache Invalidation"
  await invalidate await get first config.environment.hostnames
  config

publishDomain = flow [
  prompt "publish"
  establishLogBucket
  upsertDomain
  invalidateDomain
]

teardownDomain = flow [
  prompt "teardown"
  _teardownDomain
]


export {publishDomain, teardownDomain, invalidateDomain}
