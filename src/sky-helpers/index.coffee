# These helpers make it easier to do HTTP and AWS things with your project's context.

module.exports = (AWS) ->
  async: require("fairmont").async
  response: require("./responses")
  s3: require("./s3")(AWS)
