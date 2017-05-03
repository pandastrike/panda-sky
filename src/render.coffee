{define} = require "panda-9000"
{yaml, json} = require "panda-serialize"
{async} = require "fairmont"
{bellChar} = require "./utils"

define "render", async (env) ->
  try
    config = yield require("./configuration/compile")(env)
    console.log yaml json config.aws.cfoTemplate
  catch e
    console.error e.stack

  console.log bellChar
