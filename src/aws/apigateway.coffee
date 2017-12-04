# TODO - I implemented this during an afternoon that I thought I needed it, but
#   it turns out I don't.  So, I'll go ahead and leave this code in place, but
#   is orphaned as of this writing.  It may be handy once we start using the
#   custom domain resources and caching under the Gateway umbrella.
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
