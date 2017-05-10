{yaml, json} = require "panda-serialize"
{async, merge} = require "fairmont"

{bellChar} = require "../utils"
configuration = require "../configuration"
cloudformation = require("../configuration/cloudformation")

module.exports = async (env) ->
  try
    appRoot = process.cwd()
    config = yield configuration.compile appRoot, env
    console.log yaml json config.aws.cfoTemplate
  catch e
    console.error e.stack

  console.log bellChar

