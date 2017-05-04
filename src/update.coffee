{join} = require "path"
{define} = require "panda-9000"
{async, read, toLower} = require "fairmont"
{yaml} = require "panda-serialize"
{bellChar} = require "./utils"


define "update", async (env) ->
  try
    config = yield require("./configuration/compile")(env)
    {lambdaUpdate} = yield require("./aws/app-root")(env, config)
    api = yaml yield read join process.cwd(), "api.yaml"
    fullName = "#{config.name}-#{env}"

    # Get names of all Lambdas
    lambdas = []
    for r, resource of api.resources
      for a, action of resource.actions
         lambdas.push "#{fullName}-#{r}-#{toLower action.method}"


    yield lambdaUpdate lambdas, "#{env}-#{config.projectID}"


  catch e
    console.error e.stack
  console.log bellChar
