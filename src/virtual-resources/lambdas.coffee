import {flow} from "panda-garden"
import {sleep} from "panda-parchment"
import {syncPackage, s3} from "./bucket"

_syncCode = (config) ->
  {update} = config.sundog.Lambda()
  {stack, partitions, dispatch} = config.environment

  await update dispatch.name, stack.bucket, "package.zip"
  for _, {lambda:{name}} of partitions
    await update name, stack.bucket, "package.zip"

  config

_syncConfig = (config) ->
  await sleep 5000
  {updateConfig} = config.sundog.Lambda()
  {stack, partitions, dispatch} = config.environment

  await updateConfig dispatch.name,
    MemorySize: dispatch.memorySize
    Timeout: dispatch.timeout
    Runtime: dispatch.runtime
    Environment:
      Variables: dispatch.variables

  for _, {lambda} of partitions
    await updateConfig lambda.name,
      MemorySize: lambda.memorySize
      Timeout: lambda.timeout
      Runtime: lambda.runtime
      Environment:
        Variables: lambda.variables

  config

syncLambdaCode = flow [
  syncPackage
  _syncCode
]

syncLambdas = flow [
  syncLambdaCode
  _syncConfig
]

export {syncLambdas, syncLambdaCode}
