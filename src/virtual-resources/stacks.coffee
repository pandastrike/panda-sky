import {flow, wrap} from "panda-garden"
import {map, reduce} from "panda-river"
import {include, toJSON} from "panda-parchment"

publishStack = (sundog) ->
  do (get=undefined, create=undefined, update=undefined) ->
    {get, create, update, outputs} = sundog.CloudFormation()
    (stack) ->
      if await get stack.StackName
        try
          await update stack
        catch e
          if e.name == "ValidationError" &&
            e.message == "No updates are to be performed."
          else
            throw e
      else
        await create stack

      await do flow [
        wrap outputs stack.StackName
        map ({OutputKey, OutputValue}) -> [OutputKey]: OutputValue
        reduce include, {}
      ]

publishStacks = (config) ->
  {sundog, environment} = config
  {templates} = environment
  _publish = publishStack sundog

  for name, partition of templates.partitions
    console.log "Publishing partition #{name}..."
    parameters = await _publish partition
    config.environment.partitions[name].stackParameters = parameters
    console.log "Outputs:", toJSON parameters, true

  console.log "Publishing Dispatcher..."
  await _publish templates.core

  for name, mixin of templates.mixins
    console.log "Publishing mixin #{name}..."
    console.log "Outputs:", toJSON (await _publish mixin), true

  config

deleteStack = (sundog) ->
  do (get=undefined, destroy=undefined) ->
    {get, delete:destroy} = sundog.CloudFormation()
    (name) ->
      await destroy name if await get name

deleteStacks = (config) ->
  {sundog, environment:{templates}} = config
  {templates} = environment
  _delete = deleteStack sundog

  for name, partition of templates.partitions
    console.log "Publishing partition #{name}..."
    parameters = await _publish partition
    config.environment.partitions[name].stackParameters = parameters
    console.log "Outputs:", toJSON parameters, true

  console.log "Publishing Dispatcher..."
  await _publish templates.core

  for name, mixin of templates.mixins
    console.log "Publishing mixin #{name}..."
    console.log "Outputs:", toJSON (await _publish mixin), true

  config

export {publishStacks, deleteStacks}
