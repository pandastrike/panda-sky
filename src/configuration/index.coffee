import {flow} from "panda-garden"
import validate from "./validate"
import preprocess from "./preprocessors"
import renderCloudFormation from "./templates/cloudformation"
import renderDocs from "./templates/api-reference"

compile = flow [
  validate
  preprocess
  renderCloudFormation
  renderDocs
]

export default compile
