{async, collect, project, select} = require "fairmont"
{yaml} = require "panda-serialize"

module.exports = (s) ->

  async ->
    # Get names of all Lambdas that are part of this environment
    lambdas = yield s.lambda.list()
    names = collect project "FunctionName", lambdas

    isOurs = (str) -> ///^#{s.stackName}.+///.test str
    names = collect select isOurs, names

    console.error "'manual' deletion of lambdas", names
    yield Promise.all (s.lambda.delete name for name in names)
