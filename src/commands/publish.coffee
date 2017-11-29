{define} = require "panda-9000"
{async, first, sleep} = require "fairmont"

{bellChar} = require "../utils"
configuration = require "../configuration"

module.exports = async (env) ->
  try
    appRoot = process.cwd()
    console.error "Compiling Configuration for Publish"
    config = yield configuration.compile(appRoot, env)
    sky = yield require("../aws/sky")(env, config)

    console.error "Publishing..."
    isPublishing = yield sky.stack.publish()
    yield sky.cfo.publishWait() if isPublishing
    yield sky.stack.postPublish()
    console.error "Done.\n\n"
  catch e
    console.error "Publish Failure:"
    console.error e.stack
  console.error bellChar
  sky.cfo
