import {flow, wrap, compose} from "panda-garden"
import {include, pairs} from "panda-parchment"
import {map, reduce} from "panda-river"
import {setup, registerPartials, resolve, render} from "./templater"

renderCore = ({T, config}) ->
  config.environment.templates.core = await do flow [
      wrap resolve "main", "core.yaml"
      render T, config
    ]

  {T, config}

renderPartition = ([name, partition]) -> do flow [
    wrap resolve "main", "partition.yaml"
    render T, partition
    (result) -> "#{name}": result
  ]

renderPartitions = ({T, config}) ->
  config.environment.templates.partitions =
    await do flow [
      wrap pairs config.environment.partitions
      map renderPartition
      reduce include, {}
    ]

  {T, config}

addMixins = ({config}) ->
  config.environment.templates.mixins = await do flow [
    wrap pairs config.environment.mixins
    map ([name, {template}]) ->
      if template then "#{name}": template else {}
    reduce include, {}
  ]

  config

Render = flow [
  setup
  registerPartials resolve "main", "partials"
  renderCore
  renderPartitions
  addMixins
]

export default Render
