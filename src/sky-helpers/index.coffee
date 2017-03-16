# These helpers make it easier to do HTTP and AWS things with your project's context.

module.exports = (AWS) ->
  s3: require("./s3")(AWS)
