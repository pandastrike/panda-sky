# Sky accepts a simple configuration and then applies inference and best
# practices to build up a more detailed configuration to send to AWS.
import {flow} from "panda-garden"

import checkEnvironment from "./environment"
import setVariables from "./variables"
import setDomains from "./domains"
import setPartitions from "./partitions"
import setDispatch from "./dispatch"
import setSignatures from "./signatures"
import fetchMixins from "./mixins"

Preprocessor = flow [
  checkEnvironment
  setVariables
  setDomains
  setPartitions
  setDispatch
  setSignatures
  fetchMixins
]

export default Preprocessor
