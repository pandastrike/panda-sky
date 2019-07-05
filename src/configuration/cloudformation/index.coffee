import {merge, capitalize, empty, keys} from "panda-parchment"
import {go} from "panda-river"
import {yaml} from "panda-serialize"

import {renderCore, renderTopLevel} from "./api-core"
import {renderMixins} from "./mixins"

# The complete and rendered CloudFormation Description.
Render = (config) ->

  await go [
    renderTopLevel config
    renderCore
    renderMixins
  ]

  # Get the mixin resources
  mixins = await renderMixins config
  # Don't put mixin substack in top level if there are no resources to render.
  config.needsMixinResources = !(empty keys mixins)


  # Get the "core" sky deployment stuff, lambdas and their HTTP interface
  root = await renderTopLevel config
  core = await renderCore config

  # Return the rendered chunks to the configuration compiler top-level.
  {root, core, mixins}

export default Render
