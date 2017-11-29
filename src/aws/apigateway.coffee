{async, collect, where, empty} = require "fairmont"

module.exports = async (env, config, sky) ->
  {agw} = yield require("./index")(config.aws.region)
  APIID = null

  invalidate = async ->
    params =
      restApiId: APIID
      stageName: env

    yield agw.flushStageCache params

  list = async ->
    (yield agw.getRestApis limit: 500).items

  api = yield collect where {name: sky.stackName}, yield list()
  APIID = api[0].id if !empty api

  {invalidate, list}
