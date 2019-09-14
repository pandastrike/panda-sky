import {flow, wrap, compose} from "panda-garden"
import {include, pairs, isEmpty} from "panda-parchment"
import {map, reduce, wait} from "panda-river"
import {setup, registerPartials, resolve, render} from "./templater"

renderCustomDomain = ({T, config}) ->
  config.environment.templates.customDomain = await do flow [
      wrap resolve "custom-domain", "domain.yaml"
      render T, config
    ]

  config

Render = flow [
  setup
  renderCustomDomain
]

export default Render
