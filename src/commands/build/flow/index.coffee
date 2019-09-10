import {flow} from "panda-garden"

import {setup, cleanup} from "./temporary-directory"
import buildMain from "./webpack/main"
import buildWorkers from "./webpack/workers"
import zip from "./zip"
#import buildEdge from "./edge"

go = flow [
  setup
  buildMain
  buildWorkers
  #buildEdge
  zip
  cleanup
]


export default go
