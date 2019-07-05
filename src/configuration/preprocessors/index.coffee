# Sky accepts a simple configuration and then applies inference and best
# practices to build up a more detailed configuration to send to AWS.
import {flow} from "panda-garden"

import checkEnvironment from "./environment"
import setVariables from "./variables"
import setVPC from "./vpc"
import setPartitions from "./partitions"
import setSignatures from "./signatures"
import setDomains from "./custom-domains"
import fetchMixins from "./mixins"

Preprocessor = flow [
  checkEnvironment
  setVariables
  setVPC
  setPartitions
  setSignatures
  setDomains
  fetchMixins
]

export default Preprocessor
