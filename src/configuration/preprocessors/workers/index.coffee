import {flow} from "panda-garden"
import {clone} from "panda-parchment"

import validate from "./validate"
import checkWebpack from "./webpack"
import setTags from "./tags"
import setVault from "./vault"
import configureLambda from "./lambda"
import applySchedule from "./schedule"
import applyMixins from "./mixins"

attach = (config) ->
  worker = clone config.environment.worker
  config.environment.workers[worker.name] = worker
  config

processWorker = flow [
  validate
  checkWebpack
  setTags
  setVault
  configureLambda
  applySchedule
  applyMixins
  attach
]

handler = (config) ->
  workerList = clone config.environment.workers ? []
  config.environment.workers = {}
  for name in workerList
    config = await processWorker config, name

  config

export default handler
