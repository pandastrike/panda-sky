import {flow} from "panda-garden"
import {setup, registerPartials, resolve, render} from "./templater"

renderReference = ({T, config}) ->
  config.environment.templates.apiDocs =
    await render T, config, resolve "api-reference", "reference.pug"

  config

Render = flow [
  setup
  registerPartials resolve "api-reference", "partials"
  renderReference
]

export default Render
