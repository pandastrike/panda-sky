import {flow} from "panda-garden"

import {setup, cleanup} from "./temporary-directory"
import buildMain from "./webpack/main"
import buildWorkers from "./webpack/workers"
import buildEdges from "./webpack/edges"
import zip from "./zip"

go = flow [
  setup
  buildMain
  buildWorkers
  buildEdges
  zip
  cleanup
]

export default go
