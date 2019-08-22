# Sky accepts a simple configuration and then applies inference and best
# practices to build up a more detailed configuration to send to AWS.
import {flow} from "panda-garden"

import checkEnvironment from "./environment"
import checkWebpack from "./webpack"
import setStack from "./stack"
import setVariables from "./variables"
import setVault from "./vault"
import setDomains from "./domains"
import setDispatch from "./dispatch"
import setPreheater from "./preheaters"
import setSignatures from "./signatures"
import fetchMixins from "./mixins"
import setAPIDocs from "./docs"

Preprocessor = flow [
  checkEnvironment
  checkWebpack
  setStack
  setVariables
  setVault
  setDomains
  setDispatch
  setPreheater
  setSignatures
  fetchMixins
  setAPIDocs
]

export default Preprocessor
