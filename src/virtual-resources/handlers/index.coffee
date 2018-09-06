import {read, toLower, cat, sleep, empty, last, md5} from "fairmont"
import {yaml} from "panda-serialize"
import Bucket from "../bucket"
import Logs from "../logs"

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
    @logs = await Logs @config

  update: ->
    fail() if !@bucket.metadata
    await @bucket.syncHandlersSrc()
    await Promise.all do =>
      @Lambda.update name, @stack.src, "package.zip" for name in @names

  # Tail the logs output by the various Lambdas.
  tail: (isVerbose) ->
    time = new Date().getTime()
    latestTime = false
    latestEvent = false

    while true
      events = await @logs.scan time
      if !empty events
        events = @logs.reconcile events, latestTime, latestEvent

      if !empty events
        lastEvent = last events
        latestTime = lastEvent.timestamp
        latestEvent = md5 lastEvent.message
        @logs.output isVerbose, events
        time = latestTime - 1
      await sleep 2000

handlers = (config) ->
  h = new Handlers config
  await h.initialize()
  h

export default handlers
