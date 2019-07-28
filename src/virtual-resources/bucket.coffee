import {resolve} from "path"
import {flow} from "panda-garden"
import {keys, toJSON} from "panda-parchment"
import {exists} from "panda-quill"

s3 = (config) ->
  {bucket} = config.environment.stack
  {PUT, rmDir, list} = config.sundog.S3()
  list: -> list bucket
  upload: (key, string) ->
    console.log "Syncing file @"
    console.log "   #{bucket}"
    console.log "   #{key}"
    PUT.string bucket, key, string, ContentType: "text/yaml"
  uploadFromFile: (key, filePath) -> PUT.fileWithProgress bucket, key, filePath
  remove: (key) -> rmDir bucket, key

establishBucket = (config) ->
  {bucketTouch} = config.sundog.S3()
  {bucket} = config.environment.stack
  await bucketTouch bucket
  config

teardownBucket = (config) ->
  {bucketExists, bucketEmpty, bucketDelete} = config.sundog.S3()
  {bucket} = config.environment.stack

  console.log "-- Deleting deployment metadata."
  if await bucketExists bucket
    await bucketEmpty bucket
    await bucketDelete bucket
  else
    console.warn "No Sky metadata detected. Skipping..."

  config

scanBucket = (config) ->
  console.log "scanning orchestration bucket..."
  {list} = s3 config
  remote = partitions: [], mixins: []

  for {Key, ETag} in await list()
    if found = Key.match /partitions\/(.*?)\//
      remote.partitions.push found[1] if found[1] not in remote.partitions
    if found = Key.match /mixins\/(.*?)\//
      remote.mixins.push found[1] if found[1] not in remote.mixins

  config.environment.stack.remote = remote
  config

syncPackage = (config) ->
  {uploadFromFile} = s3 config
  path = resolve process.cwd(), "deploy", "package.zip"
  console.log "uploading #{path}"

  if await exists path
    await uploadFromFile "package.zip", path
  else
    throw new Error "Unable to find #{path}"

  config


export {establishBucket, teardownBucket, scanBucket, syncPackage, s3}
