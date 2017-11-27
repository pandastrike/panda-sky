{define} = require "panda-9000"
{async, first, sleep} = require "fairmont"

{bellChar} = require "../utils"
configuration = require "../configuration"

module.exports = async (env) ->
  try
    appRoot = process.cwd()
    console.error "Compiling Configuration for Publish"
    config = yield configuration.compile(appRoot, env)
    stack = yield require("../aws/cloudformation")(env, config)

    console.error "Publishing..."
    id = yield stack.publish()
    if id
      yield stack.publishWait id
    yield stack.postPublish()
    console.error "Done.\n\n"
  catch e
    console.error "Publish Failure:"
    console.error e.stack
  console.error bellChar
  stack
