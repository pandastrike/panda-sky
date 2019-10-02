import {flow} from "panda-garden"
import {dashed, merge, second, toJSON, sleep, isEmpty} from "panda-parchment"

import {syncEdges, s3} from "./bucket"
import {cloudformation} from "./stacks"

publishLambdas = (config) ->
  {upload} = s3 config
  {format, publish} = cloudformation config
  {update} = config.sundog.Lambda()
  {templates, cache, stack} = config.environment

  unless isEmpty config.environment.cache.edges
    console.log "upserting edge lambda deployments..."
    await upload "custom-domain-lambdas.yaml", templates.edges
    await publish format "#{cache.stack}-lambdas", "custom-domain-lambdas.yaml"

    for edgeName, edge of config.environment.cache.edges
      await update edge.lambda.name, stack.bucket, "edge-code/#{edgeName}.zip"

    console.log "edge lambda update complete."

  config

publishLambdaVersions = (config) ->
  unless isEmpty config.environment.cache.edges
    {publish, listVersions} = config.sundog.Lambda()

    for _, edge of config.environment.cache.edges
      console.log "publishing edge lambda #{edge.lambda.name}"
      await publish edge.lambda.name

    for key, edge of config.environment.cache.edges
      versions = await listVersions edge.lambda.name
      versions.sort (a, b) -> b.Version - a.Version
      config.environment.cache.edges[key].arn = versions[1].FunctionArn

  config

setupEdgeLambdas = flow [
  syncEdges
  publishLambdas
  publishLambdaVersions
]

teardownEdgeLambdas = flow [
  (config) ->
    console.warn "Cannot delete this custom domain's edge lambdas and their published versions because their replcations must be cleared by AWS first. Please delete in Console in a couple hours"
    config
]


export {setupEdgeLambdas, teardownEdgeLambdas}
