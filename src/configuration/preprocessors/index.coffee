# Sky accepts a simple configuration and then applies inference and best
# practices to build up a more detailed configuration to send to AWS.
import {go} from "panda-river"

import checkEnvironment from "./environment"
import setVariables from "./variables"
import setVPC from "./vpc"
import setPartitions from "./partitions"
import setSignatures from "./signatures"
import setDomains from "./custom-domains"
import fetchMixins from "./mixins"

Preprocessor = (config) ->

  await go [
    checkEnvironment config
    setVariables
    setVPC
    setPartitions
    setSignatures
    setDomains
    fetchMixins
  ]

export default Preprocessor
