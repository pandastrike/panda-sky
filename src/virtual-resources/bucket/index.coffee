###
This section of Sky models the deployment stack (which is a collection of AWS resources / services) as an AWS service.  Here is the S3 bucket used to orchestrate state and code.
###

import {md5} from "fairmont"
import {read} from "panda-quill"
import {keys, cat, empty, min, remove, toJSON, clone} from "panda-parchment"
import {yaml} from "panda-serialize"

Metadata = class Metadata
  constructor: (@config) ->
    @name = @config.aws.stack.name
    @src = @config.aws.stack.src
    @pkg = @config.aws.stack.pkg
    @apiDef = @config.aws.stack.apiDef
    @skyDef = @config.aws.stack.skyDef
    @templates = @config.aws.templates
    @s3 = @config.sundog.S3()

  initialize: ->
    try
      @metadata = await @getState() # memcaches ".sky" fetch
      @cloudformationParameters =
        StackName: @name
        TemplateURL: "https://#{@src}.s3.amazonaws.com/template.yaml"
        Capabilities: ["CAPABILITY_IAM"]
        Tags: @config.tags
      @intermediateCloudformationParameters =
        StackName: @name
        TemplateURL: "https://#{@src}.s3.amazonaws.com/template-intermediate.yaml"
        Capabilities: ["CAPABILITY_IAM"]
        Tags: @config.tags
    catch e
      return # swallow the 404 error, there's probably no bucket to read

  # All the properties and data the orchestration bucket tracks.
  api: =>
    isCurrent: =>
      local = md5 await read @apiDef
      if local == @metadata.api then true else false
    update: =>
      await @s3.PUT.file @src, "api.yaml", @apiDef

  handlers: =>
    isCurrent: =>
      local = md5 await read(@pkg, "buffer")
      if local == @metadata.handlers then true else false

    update: => await @s3.PUT.file @src, "package.zip", @pkg

  skyConfig: =>
    isCurrent: =>
      local = md5 await read @skyDef
      if local == @metadata.sky then true else false

    update: => await @s3.PUT.file @src, "sky.yaml", @skyDef

  permissions: =>
    isCurrent: =>
      local = md5 toJSON @config.policyStatements
      if local == @metadata.permissions then true else false

    update: => await @s3.PUT.string @src, "permissions.json",
      toJSON(@config.policyStatements), ContentType: "text/json"

  stacks: =>
    update: =>
      # Upload the root stack...
      await @s3.PUT.string @src, "template.yaml", (yaml @templates.root),
        ContentType: "text/yaml"

      # Now the intermediate based off of the root.
      intermediate = clone @templates.root
      intermediate.Resources.SkyCore.Properties.TemplateURL = "https://#{@src}.s3.amazonaws.com/templates/core/intermediate.yaml"
      await @s3.PUT.string @src, "template-intermediate.yaml",
        (yaml intermediate), ContentType: "text/yaml"

      # Now all the nested children...
      for key, stack of @templates.core
        await @s3.PUT.string @src, "templates/#{key}",
          stack, ContentType: "text/yaml"
      for key, stack of @templates.mixins
        await @s3.PUT.string @src, "templates/mixins/#{key}.yaml",
          stack, ContentType: "text/yaml"

  needsUpdate: ->
    # Examine core stack resources to update the CloudFormation stack.
    dirtyAPI = !(await @api().isCurrent()) || !(await @skyConfig().isCurrent()) || !@permissions().isCurrent()

    # See if lambda handlers are up to date.
    dirtyLambda = !(await @handlers().isCurrent())
    {dirtyAPI, dirtyLambda}

  create: ->
    await @s3.bucketTouch @src
    await @sync()

  delete: ->
    if await @s3.bucketExists @src
      console.log "-- Deleting deployment metadata."
      await @s3.bucketEmpty @src
      await @s3.bucketDelete @src
    else
      console.warn "No Sky metadata detected for this deployment. Moving on..."

  # This updates the contents of the bucket, but not the state MD5 hashes.
  sync: ->
    await @api().update()
    await @skyConfig().update()
    await @handlers().update()
    await @permissions().update()
    await @stacks().update()

  syncHandlersSrc: -> await @handlers().update()

  # Holds the deployed state of resources as an MD5 hash of configuration files within a file named ".sky"
  getState: ->
    try
      yaml await @s3.get @src, ".sky"
    catch e
      false

  syncState: (endpoint) ->
    data =
      api: md5 await read @apiDef
      handlers: md5 (await read @pkg, "buffer")
      sky: md5 await read @skyDef
      permissions: md5 toJSON @config.policyStatements
      endpoint: endpoint

    await @s3.PUT.string @src, ".sky", (yaml data), ContentType: "text/yaml"

metadata = (config) ->
  M = new Metadata config
  await M.initialize()
  M

export default metadata
