import {flow} from "panda-garden"
import validate from "./validate"
import preprocess from "./preprocessors"
import render from "./cloudformation"
import renderDocs from "./api-reference"

compile = flow [
  validate
  preprocess
  render
  renderDocs
]

export default compile
