import {join} from "path"
import {flow, wrap} from "panda-garden"
import {map, reduce, wait} from "panda-river"
import {keys, dashed, include, isEmpty, merge} from "panda-parchment"
import {yaml} from "panda-serialize"
import {s3} from "./bucket"
import {_syncCode} from "./lambdas"

cloudformation = (config) ->
  {get, create, put, outputs, delete:_delete} = config.sundog.CloudFormation()
  {bucket} = config.environment.stack

  publish: (stack) ->
    if result = await get stack.StackName
      if result.StackStatus in ["ROLLBACK_COMPLETE", "ROLLBACK_FAILED"]
        console.warn "removing inert stack #{stack.StackName}"
        await _delete stack.StackName

    await put stack
  teardown: (name) -> _delete name
  format: (name, key, parameters) ->
    StackName: name
    TemplateURL: "https://#{bucket}.s3.amazonaws.com/#{key}"
    Capabilities: ["CAPABILITY_IAM"]
    Parameters: do ->
      if parameters
        (ParameterKey: k, ParameterValue: v for k, v of parameters)
      else
        undefined

  read: (name) ->
    await do flow [
      wrap outputs name
      map ({OutputKey, OutputValue}) -> [OutputKey]: OutputValue
      reduce include, {}
    ]

teardownStacks = (config) ->
  {teardown} = cloudformation config
  {dispatch, mixins, stack} = config.environment

  console.log "Mixin Teardown"
  await Promise.all (teardown stack for name, {stack} of mixins)

  if stack.workers?
    console.log "Worker Teardown"
    await teardown stack.workers

  console.log "Dispatcher Teardown"
  await teardown dispatch.name

  config

teardownOld = (config) ->
  {teardown} = cloudformation config
  {remove} = s3 config
  {stack:{remote}, mixins} = config.environment

  # Remove stacks removed from the configuration.
  for name in remote.mixins when name not in keys mixins
    console.log "Mixin Teardown: #{name}"
    await teardown dashed "#{config.name} #{config.env} mixin #{name}"
    await remove join "mixins", name

  config

upsertDispatch = (config) ->
  {publish, format, read} = cloudformation config
  {upload, remove} = s3 config
  {dispatch, templates} = config.environment

  console.log "Dispatcher Deploy"
  await remove "dispatch"
  key = join "dispatch", "index.yaml"
  await upload key, templates.dispatch
  await publish format dispatch.name, key
  parameters = await read dispatch.name
  config.environment.dispatch.stackParameters = parameters
  unless isEmpty parameters
    console.log "Outputs:"
    console.log yaml parameters

  config

upsertWorkers = (config) ->
  {publish, format, read} = cloudformation config
  {upload, remove} = s3 config
  {templates, stack} = config.environment

  if templates.workers?
    console.log "Workers Deploy"
    await remove "workers"
    key = join "workers", "index.yaml"
    await upload key, templates.workers
    await publish format stack.workers, key
    console.log "Workers Deploy Complete"

  config

matchMixin = (dispatch, mixinName) ->
  parameters = []
  {mixins, stackParameters} = dispatch
  if mixins? && stackParameters? && (mixinName in mixins)
    parameters.push stackParameters

  if isEmpty parameters
    undefined
  else
    # TODO: This is a placeholder.
    merge parameters...


upsertMixins = (config) ->
  {publish, read, format} = cloudformation config
  {upload} = s3 config
  {mixins, templates, dispatch} = config.environment

  for name, template of templates.mixins
    console.log "Mixin Deploy: #{name}"
    {stack, vpc, beforeHook} = mixins[name]

    key = join "mixins", name, "index.yaml"
    await upload key, template

    if beforeHook
      console.log "  - Triggering before hook..."
      await beforeHook config

    parameters = matchMixin dispatch, name if vpc
    await publish format stack, key, parameters

    parameters = await read stack
    config.environment.mixins[name].stackParameters = parameters
    console.log "Outputs:"
    console.log yaml parameters unless isEmpty parameters

  config

syncStacks = flow [
  teardownOld
  upsertDispatch
  upsertWorkers
  upsertMixins
  _syncCode
]

export {syncStacks, teardownStacks, cloudformation}
