import {join} from "path"
import {flow, wrap} from "panda-garden"
import {map, reduce} from "panda-river"
import {keys, dashed, include, toJSON} from "panda-parchment"
import {s3} from "./bucket"

cloudformation = (config) ->
  {get, create, put, outputs, delete:_delete} = config.sundog.CloudFormation()
  {bucket} = config.environment.stack

  publish: (stack) ->
    if result = await get stack.StackName
      if result.StackStatus == "ROLLBACK_COMPLETE"
        await _delete stack.StackName

    await put stack
  teardown: (name) -> _delete name
  format: (name, key) ->
      StackName: name
      TemplateURL: "https://#{bucket}.s3.amazonaws.com/#{key}"
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
  for name in remote.mixins when name not in keys mixins
    console.log "Mixin Teardown: #{name}"
    await teardown dashed "#{config.name} #{config.env} mixin #{name}"
    await remove join "mixins", name

  for name in remote.partitions when name not in keys partitions
    console.log "Partition Teardown: #{name}"
    await teardown dashed "#{config.name} #{config.env} #{name}"
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

announce = (config) ->
  console.log "Deploy ready at https://#{config.environment.dispatch.hostname}"
  config

syncStacks = flow [
  teardownOld
  upsertPartitions
  upsertDispatch
  upsertMixins
  announce
]

export {syncStacks, teardownStacks, cloudformation}
