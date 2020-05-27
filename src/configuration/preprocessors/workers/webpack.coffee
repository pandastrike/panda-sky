
handler = (config) ->
  config.environment.worker.webpack ?= {}
  config.environment.worker.webpack.target ?= "12.16"
  config.environment.worker.webpack.mode ?= "production"

  config

export default handler
