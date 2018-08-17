YAML = require "js-yaml"
{yaml, json} = require "panda-serialize"
{define} = require "panda-9000"
{async, merge} = require "fairmont"

{bellChar} = require "../utils"
configuration = require "../configuration"
cloudformation = require("../configuration/cloudformation")

module.exports = async (env, {profile}) ->
  try
    appRoot = process.cwd()
    config = yield configuration.compile appRoot, env, profile
    console.error yaml config.aws.cfoTemplate
  catch e
    console.error e
