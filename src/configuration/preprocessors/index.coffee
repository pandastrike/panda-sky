# Sky tries to accept only simple configuration and then apply them in a clever
# way to AWS.  That requires building up the more detialed configuration the
# underlying configuraiton requires.  These preprocessors do quite a bit to
# add that layer of sophistication.
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
