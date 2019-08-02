# Sky accepts a simple configuration and then applies inference and best
# practices to build up a more detailed configuration to send to AWS.
import {flow} from "panda-garden"

import checkEnvironment from "./environment"
import setStack from "./stack"
import setVariables from "./variables"
import setDomains from "./domains"
import setPartitions from "./partitions"
import setDispatch from "./dispatch"
import setPreheater from "./preheaters"
import setSignatures from "./signatures"
import fetchMixins from "./mixins"

Preprocessor = flow [
  checkEnvironment
  setStack
  setVariables
  setDomains
  setPartitions
  setDispatch
  setPreheater
  setSignatures
  fetchMixins
]

export default Preprocessor
