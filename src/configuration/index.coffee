import {flow} from "panda-garden"
import validate from "./validate"
import preprocess from "./preprocessors"
import render from "./templates"

compile = flow [
  validate
  preprocess
  render
]

export default compile
