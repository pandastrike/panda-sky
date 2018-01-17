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

  async ->
    fail() if !yield s.meta.current.fetch()
    names = yield list()
    republish = ->
      s.lambda.update(name, s.srcName, "package.zip") for name in names

    yield s.meta.handlers.update()
    yield Promise.all republish()
