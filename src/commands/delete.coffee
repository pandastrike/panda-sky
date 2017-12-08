{define, run} = require "panda-9000"
{async, first, sleep} = require "fairmont"

{bellChar, outputDuration} = require "../utils"
configuration = require "../configuration"

START = 0
module.exports = (start, env) ->
  START = start
  run "delete", [env]

define "delete", async (env) ->
  try
    appRoot = process.cwd()
    config = yield configuration.compile(appRoot, env)
    sky = yield require("../aws/sky")(env, config)

    console.error "Deleting Sky deployment..."
    isDeleting = yield sky.cfo.delete()
    if isDeleting
      console.error "-- Waiting for deletion to complete."
      yield sky.cfo.deleteWait()
    else
      console.error "WARNING: No Sky stack detected. Now checking for metadata."

    yield sky.stack.postDelete()
    console.error "Done. (#{outputDuration START})\n\n"
  catch e
    console.error e.stack
  console.error bellChar
