{define, run} = require "panda-9000"
{async, first, sleep} = require "fairmont"

{bellChar, outputDuration} = require "../utils"
configuration = require "../configuration"

START = 0
module.exports = (start, env, {profile}) ->
  START = start
  run "delete", [env, profile]

define "delete", async (env, profile) ->
  try
    appRoot = process.cwd()
    config = yield configuration.compile(appRoot, env, profile)
    sky = yield require("../aws/sky")(env, config)

    console.error "Deleting Sky deployment..."
    isDeleting = yield sky.stack.delete()
    if isDeleting
      console.error "-- Waiting for stack deletion to complete."
      yield sky.cfo.deleteWait()
    else
      console.error "WARNING: No Sky stack detected. Now checking for metadata."

    yield sky.stack.postDelete()
    console.error "Done. (#{outputDuration START})\n\n"
  catch e
    console.error e.stack
  console.error bellChar
