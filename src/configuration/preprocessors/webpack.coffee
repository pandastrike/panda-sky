
handler = (config) ->
  config.environment.webpack ?= {}
  config.environment.webpack.target ?= "12.16"
  config.environment.webpack.mode ?= "production"

  config

export default handler
