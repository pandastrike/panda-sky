
handler = (config) ->
  config.environment.worker.webpack ?= {}
  config.environment.worker.webpack.target ?= "10.16"
  config.environment.worker.webpack.mode ?= "production"

  config

export default handler
