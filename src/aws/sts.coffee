{async, cat} = require "fairmont"

module.exports = async (config) ->
  {sts} = yield require("./index")(config.aws.region, config.profile)

  whoAmI = async -> yield sts.getCallerIdentity()

  {whoAmI}
