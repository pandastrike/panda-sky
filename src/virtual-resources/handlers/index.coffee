import {read, toLower, cat} from "fairmont"
import {yaml} from "panda-serialize"
import Bucket from "../bucket"

fail = ->
  console.warn "WARNING: No Sky metadata detected for this deployment.  This feature is meant only for pre-existing Sky deployments and will not continue."
  console.log "Done."
  process.exit()

Handlers = class Handlers
  constructor: (@config) ->
    @stack = @config.aws.stack
    @Lambda = @config.sundog.Lambda

  initialize: ->
    api = yaml await read @stack.apiDef
    names =
      for r, resource of api.resources
        for m, method of resource.methods
          "#{@stack.name}-#{r}-#{toLower m}"

    @names = cat names...
    @bucket = await Bucket @config

  update: ->
    fail() if !@bucket.metadata
    await @bucket.syncHandlersSrc()
    await Promise.all do ->
      @Lambda.update name, @stack.src, "package.zip" for name in @names

handlers = (config) ->
  h = new Handlers config
  await h.initialize()
  h

export default handlers
