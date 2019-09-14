import {flow} from "panda-garden"
import {clone} from "panda-parchment"

import validate from "./validate"
import checkWebpack from "./webpack"
import setTags from "./tags"
import setVault from "./vault"
import configureLambda from "./lambda"
import applyMixins from "./mixins"

attach = (config) ->
  edge = clone config.environment.edge
  config.environment.cache.edges[edge.type] = edge
  config

processEdgeLambda = flow [
  validate
  checkWebpack
  setTags
  setVault
  configureLambda
  applyMixins
  attach
]

handler = (config) ->
  list = clone config.environment.cache.edges ? []
  config.environment.cache.edges = {}
  for type in list
    config = await processEdgeLambda config, type

  config

export default handler
