import {md5} from "fairmont"
import {empty, compact, cat, first, rest} from "panda-parchment"
import {collect} from "panda-river"
import print from "./print"
import parse from "./parse"

Logs = class Logs
  constructor: (@config) ->
    @stack = @config.aws.stack
    @logs = @config.sundog.CloudWatchLogs()

  # This lays out one scan cycle.
  scan: (timeKey) ->
    # Get any CloudWatch log group belonging to this deployment.
    groups = await @logs.groupList "/aws/lambda/#{@stack.name}"
    return [] if empty groups

    # Get the most recent log streams in each group.
    streams =
      for g in groups
        stream = await @logs.latest g.logGroupName
        stream.group = g.logGroupName if stream
        stream
    streams = collect compact streams
    return [] if empty streams

    # Get the most recent log events for each stream.
    events =
      for stream in streams
        {group, logStreamName: name} = stream
        await @logs.tail group, name, timeKey

    # Output a flat array, timesorted.
    cat(events...).sort (a, b) -> a.timestamp - b.timestamp


  # Seamlessly stitch together the events that were just fetched with the ones that are already written to the screen.
  reconcile: (events, time, event) ->
    return events if !time && !event
    while true
      return [] if empty events
      e = first events
      if e.timestamp == time && md5(e.message) == event
        return rest events
      else
        events = rest events

  output: (isVerbose, events) ->
    print isVerbose, parse(e) for e in events

logs = (config) -> new Logs config

export default logs
