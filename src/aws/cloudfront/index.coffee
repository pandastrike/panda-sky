{async} = require "fairmont"

module.exports = async (config, env) ->

  {fetch, create, sync, update, destroyDistro} = yield require("./distro")(config, env)
  url = yield require("../dns")(config)

  # Search the user's current distributions for ones that match app deployment
  # needs. If we don't find one, create it. If it's misconfigured, update it.
  deploy = async ->
    if distro = yield fetch()
      d = yield update distro
    else
      d = yield create()
    yield sync d
    yield url.set d

  destroy = async ->
    if d = yield fetch()
      yield destroyDistro d
      yield url.destroy d

  {deploy, destroy}
