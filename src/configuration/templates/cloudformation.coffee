import {flow, wrap, compose} from "panda-garden"
import {include, pairs} from "panda-parchment"
import {map, reduce, wait} from "panda-river"
import {setup, registerPartials, resolve, render} from "./templater"

renderDispatch = ({T, config}) ->
  config.environment.templates.dispatch = await do flow [
      wrap resolve "main", "dispatch.yaml"
      render T, config
    ]

  {T, config}

renderCustomDomain = ({T, config}) ->
  config.environment.templates.customDomain = await do flow [
      wrap resolve "custom-domain.yaml"
      render T, config
    ]

  {T, config}

renderPartition = (T, path = resolve "main", "partition.yaml") ->
  ([name, partition]) ->
    [name]: await render T, partition, path

renderPartitions = ({T, config}) ->
  config.environment.templates.partitions =
    await do flow [
      wrap pairs config.environment.partitions
      wait map renderPartition T
      reduce include, {}
    ]

  console.log config.environment.templates.partitions

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
  renderCustomDomain
  renderPartitions
  addMixins
]

export default Render
