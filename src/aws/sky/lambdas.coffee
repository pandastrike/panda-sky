{async, read, toLower} = require "fairmont"
{yaml} = require "panda-serialize"

module.exports = (s) ->
  update = async ->
    fail() if !yield s.meta.current.fetch()
    names = yield list()
    republish = ->
      s.lambda.update(name, s.srcName, "package.zip") for name in names

    yield s.meta.handlers.update()
    yield Promise.all republish()
    #yield s.agw.invalidate()

  # Get names of all Lambdas
  list = async ->
    api = yaml yield read s.apiDef
    lambdas = []
    for r, resource of api.resources
      for m, method of resource.methods
        lambdas.push "#{s.config.name}-#{s.env}-#{r}-#{toLower m}"
    lambdas

  fail = ->
    console.error """
    WARNING: No Sky metadata detected for this deployment.  'sky update' is
    meant only for pre-existing Sky deployments and will not continue.

    Done.
    """
    process.exit()

  {update}
