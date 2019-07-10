import {flow} from "panda-garden"
import renderCloudFormation from "./cloudformation"
import renderDocs from "./api-reference"

render = flow [
  renderCloudFormation
  renderDocs
]

export default render
