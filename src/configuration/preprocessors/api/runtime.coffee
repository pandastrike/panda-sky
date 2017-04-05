module.exports = (config) ->
  # TODO: Expand this beyond Node
  if !config.aws.runtime
    config.aws.runtime = "nodejs4.3"

  supportedRuntimes = ["nodejs4.3", "nodejs6.10"]

  if config.aws.runtime not in supportedRuntimes
    console.error "The requested Lambda runtime, #{config.aws.runtime}, is not " +
      "currently supported by Panda Sky. Select a value among: #{supportedRuntimes}"

  config
