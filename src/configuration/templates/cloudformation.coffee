import {flow, wrap, compose} from "panda-garden"
import {include, pairs, isEmpty} from "panda-parchment"
import {map, reduce, wait} from "panda-river"
import {setup, registerPartials, resolve, render} from "./templater"

renderDispatch = ({T, config}) ->
  config.environment.templates.dispatch = await do flow [
      wrap resolve "main", "dispatch.yaml"
      render T, config
    ]

  {T, config}

renderWorkers = ({T, config}) ->
  unless isEmpty config.environment.workers
    config.environment.templates.workers = await do flow [
      wrap resolve "worker.yaml"
      render T, config
    ]

  {T, config}

renderCustomDomain = ({T, config}) ->
  config.environment.templates.customDomain = await do flow [
      wrap resolve "custom-domain.yaml"
      render T, config
    ]

  {T, config}

addMixins = ({config}) ->
  config.environment.templates.mixins =
    await do flow [
      wrap pairs config.environment.mixins
      map ([name, {template}]) -> [name]: template if template
      reduce include, {}
    ]

  config

Render = flow [
  setup
  registerPartials resolve "main", "partials"
  renderDispatch
  renderWorkers
  renderCustomDomain
  addMixins
]

export default Render
