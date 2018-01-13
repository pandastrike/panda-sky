{async, read, toLower, cat, empty, collect, compact, project, sleep, last, md5, rest, first} = require "fairmont"
{yaml} = require "panda-serialize"

module.exports = (s) ->
  # Get names of all Lambdas
  list = async ->
    api = yaml yield read s.apiDef
    names =
      for r, resource of api.resources
        for m, method of resource.methods
          "#{s.stackName}-#{r}-#{toLower m}"
    cat names...

  fail = ->
    console.error """
    WARNING: No Sky metadata detected for this deployment.  This feature is
    meant only for pre-existing Sky deployments and will not continue.

    Done.
    """
    process.exit()

  # This lays out one scan cycle.
  scanLogs = async (timeKey) ->
    # Get any CloudWatch log group belonging to this deployment.
    groups = yield s.logs.listGroups "/aws/lambda/#{s.stackName}"
    return [] if empty groups

    # Get the most recent log streams in each group.
    streams =
      for g in groups
        stream = yield s.logs.getNewestStream g.logGroupName
        stream.group = g.logGroupName if stream
        stream
    streams = collect compact streams
    return [] if empty streams

    # Get the most recent log events for each stream.
    events =
      for stream in streams
        {group, logStreamName: name} = stream
        yield s.logs.tailEvents group, name, timeKey

    # Output a flat array, timesorted.
    cat(events...).sort (a, b) -> a.timestamp - b.timestamp


  # Seamlessly stitch together the events that were just fetched with the ones that are already written to the screen.
  reconcileEvents = (events, time, event) ->
    return events if !time && !event
    while true
      return [] if empty events
      e = first events
      if e.timestamp == time && md5(e.message) == event
        return rest events
      else
        events = rest events


  outputLogs = (events) ->
    console.error e.timestamp, e.message for e in events

  # Tail the logs output by the various Lambdas.
  tail = async ->
      fail() if !yield s.meta.current.fetch()
      time = new Date().getTime()
      latestTime = false
      latestEvent = false

      while true
        events = yield scanLogs time
        if !empty events
          events = reconcileEvents events, latestTime, latestEvent

        if !empty events
          lastEvent = last events
          latestTime = lastEvent.timestamp
          latestEvent = md5 lastEvent.message
          outputLogs events
          time = latestTime - 1

        yield sleep 2000


  update = async ->
    fail() if !yield s.meta.current.fetch()
    names = yield list()
    republish = ->
      s.lambda.update(name, s.srcName, "package.zip") for name in names

    yield s.meta.handlers.update()
    yield Promise.all republish()

  {tail, update}
