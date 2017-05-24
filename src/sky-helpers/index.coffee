# These helpers make it easier to do HTTP and AWS things with your project's context.
#

# Provides the dispatching logic so Sky apps don't need to know how we
# structure things.
dispatch = (handlers) ->
  (request, context, callback) ->
    console.log "Dispatching to '#{context.functionName}' handler"
    handler = handlers[context.functionName]
    unless typeof handler is 'function'
      console.error "Failed to execute: " + context.functionName
      return callback new response.Internal()

    handler request, context
    .then (result) -> callback null, result
    .catch (e) -> callback e


module.exports = (AWS) ->
  async: require("fairmont").async
  response: require("./responses")
  s3: require("./s3")(AWS)
  method: require "./method"
  dispatch: dispatch
