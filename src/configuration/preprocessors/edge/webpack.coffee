
handler = (config) ->
  config.environment.edge.webpack ?= {}
  config.environment.edge.webpack.target ?= "10.16"
  config.environment.edge.webpack.mode ?= "production"

  config

export default handler
