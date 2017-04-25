{yaml, json} = require "panda-serialize"
{async, first, sleep} = require "fairmont"
{bellChar} = require "./utils"

module.exports = async (env) ->
  try
    config = yield require("./configuration/compile")(env)
    console.log yaml json config.aws.cfoTemplate
    #stack = yield require("./aws/cloudformation")(env, config)

    #id = yield stack.publish()
    #if id
      #console.log "Waiting for deployment to be ready."
      #yield stack.publishWait id
    #yield stack.postPublish()
    #console.log "Done"
  catch e
    console.error e.stack

  console.log bellChar

