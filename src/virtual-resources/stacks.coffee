import {join} from "path"
import {flow, wrap} from "panda-garden"
import {map, reduce} from "panda-river"
import {include, toJSON} from "panda-parchment"
import {s3} from "./bucket"

cloudformation = (config) ->
  {get, create, put, outputs, delete:_delete} = config.sundog.CloudFormation()
  {bucket} = config.environment.stack

  publish: (stack) -> await put stack
  teardown: (name) -> _delete name
  format: (name, key) ->
      StackName: name
      TemplateURL: join "https://#{bucket}.s3.amazonaws.com", key
      Capabilities: ["CAPABILITY_IAM"]
  read: flow [
    outputs
    map ({OutputKey, OutputValue}) -> [OutputKey]: OutputValue
    reduce include, {}
  ]

teardownStacks = (config) ->
  {teardown} = cloudformation config
  {dispatch, partitions, mixins} = config.environment

  console.log "Mixin Teardown"
  await Promise.all (teardown stack for name, {stack} of mixins)

  console.log "Dispatcher Teardown"
  await teardown dispatch.name

  console.log "Partition Teardown"
  await Promise.all (teardown stack for name, {stack} of partitions)

  config

teardownOld = (config) ->
  {teardown} = cloudformation config
  {remove} = s3 config
  {stack:{remote}, partitions, mixins} = config.environment

  # Remove stacks removed from the configuration.
  for name, {stack} of mixins when name not in remote.mixins
    console.log "Mixin Teardown: #{name}"
    await teardown stack
    await remove join "mixins", name

  for name, {stack} of partitions when name not in remote.partitions
    console.log "Partition Teardown: #{name}"
    await teardown stack
    await remove join "partitions", name

  config

upsertPartitions = (config) ->
  {publish, read, format} = cloudformation config
  {upload} = s3 config
  {partitions, templates} = config.environment

  for name, template of templates.partitions
    console.log "Partition Deploy: #{name}"
    {stack} = partitions[name]
    key = join "partitions", name, "index.yaml"
    await upload key, template
    await publish format stack, key
    parameters = await read stack
    config.environment.partitions[name].stackParameters = parameters
    console.log "Outputs:", toJSON parameters, true

  config

upsertDispatch = (config) ->
  {publish, format} = cloudformation config
  {upload, remove} = s3 config
  {dispatch, templates} = config.environment

  console.log "Dispatcher Deploy"
  await remove "dispatch"
  key = join "dispatch", "index.yaml"
  await upload key, templates.dispatch
  await publish format dispatch.name, key

  config

upsertMixins = (config) ->
  {publish, read, format} = cloudformation config
  {upload} = s3 config
  {mixins, templates} = config.environment

  for name, template of templates.mixins
    console.log "Mixin Deploy: #{name}"
    {stack} = mixins[name]
    key = join "mixins", name, "index.yaml"
    await upload key, template
    await publish format stack, key
    parameters = await read stack
    config.environment.mixins[name].stackParameters = parameters
    console.log "Outputs:", toJSON parameters, true

  config

syncStacks = flow [
  teardownOld
  upsertPartitions
  upsertDispatch
  upsertMixins
]

export {syncStacks, teardownStacks}
