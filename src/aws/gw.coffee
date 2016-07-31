{async, collect, where, empty} = require "fairmont"

module.exports = async (config) ->
  {gw} = yield require("./index")(config.aws.region)

  # Assuming the API is deployed, determine its endpoint, without the stage path
  getEndpoint: async ->
    {items} = yield gw.getRestApis { limit: 500 }
    matches = collect where {name: config.name}, items
    throw new Error("Unable to find API #{config.name}") if empty matches
    "#{matches[0].id}.execute-api.#{config.aws.region}.amazonaws.com"
