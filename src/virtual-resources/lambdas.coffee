import {flow} from "panda-garden"
import {sleep} from "panda-parchment"
import {syncPackage, syncWorkers, s3} from "./bucket"

_syncCode = (config) ->
  {update} = config.sundog.Lambda()
  {stack, dispatch} = config.environment

  console.log "syncing lambda code"
  await update dispatch.name, stack.bucket, "package.zip"

  for name, worker of config.environment.workers
    await update worker.lambda.name, stack.bucket, "worker-code/#{name}.zip"

  config

_syncConfig = (config) ->
  await sleep 5000
  {updateConfig} = config.sundog.Lambda()
  {stack, dispatch} = config.environment

  console.log "syncing lambda configurations"
  await updateConfig dispatch.name,
    MemorySize: dispatch.memorySize
    Timeout: dispatch.timeout
    Runtime: dispatch.runtime

  for name, worker of config.environment.workers
    await updateConfig worker.lambda.name,
      MemorySize: worker.lambda.memorySize
      Timeout: worker.lambda.timeout
      Runtime: worker.lambda.runtime

  config

finalMessage = (config) ->
  console.log "Deploy ready at https://#{config.environment.dispatch.hostname}"
  config

syncLambdaCode = flow [
  syncPackage
  syncWorkers
  _syncCode
  finalMessage
]

syncLambdas = flow [
  syncPackage
  syncWorkers
  _syncCode
  _syncConfig
  finalMessage
]

export {syncLambdas, syncLambdaCode, _syncCode}
