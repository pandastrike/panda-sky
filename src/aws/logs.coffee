{async, cat, empty} = require "fairmont"


module.exports = async (env, config) ->
  {logs} = yield require("./index")(config.aws.region)

  # Returns data on a group or groups given an input prefix.
  listGroups = async (prefix, current=[], token) ->
    params = logGroupNamePrefix: prefix
    params.nextToken = token if token
    {logGroups, nextToken} = yield logs.describeLogGroups params
    current = cat current, logGroups
    if nextToken
      yield listGroups prefix, current, nextToken
    else
      current

  getNewestStream = async (name) ->
    params =
      logGroupName: name
      orderBy: "LastEventTime"
      descending: true
      limit: 1

    {logStreams} = yield logs.describeLogStreams params
    if empty logStreams
      undefined
    else
      logStreams[0]

  tailEvents = async (group, stream, time, current=[], token=false) ->
    params =
      logGroupName: group
      logStreamName: stream
      startTime: time
      startFromHead: true
    params.nextToken = token if token

    {events, nextForwardToken} = yield logs.getLogEvents params
    current = cat current, events
    if nextForwardToken != token
      yield tailEvents group, stream, time, current, nextForwardToken
    else
      current


  # Return exposed functions.
  {listGroups, getNewestStream, tailEvents}
