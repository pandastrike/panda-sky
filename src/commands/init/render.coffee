import {resolve} from "path"
import PandaTemplate from "panda-template"
import {read, write, exists} from "panda-quill"
import {safe_cp, safe_mkdir} from "../../utils"

Render = (name, config) ->
  # Drop in the file stubs.
  src = (file) -> resolve __dirname, "..", "..", "..", "..", "..",
    "init", name, "#{file}"
  target = (file) -> resolve process.cwd(), file

  T = new PandaTemplate()
  render = (src, target) ->
    if await exists target
      console.warn "Warning: #{target} exists. Skipping."
      return
    template = await read src
    output = T.render template, config
    await write target, output

  # Drop in an API description stub.
  await safe_cp (src "api.yaml"), (target "api.yaml")

  # Drop in a Panda Sky configuration stub.
  await render (src "sky.yaml"), (target "sky.yaml")

  # Drop in a dispatcher stub and corresponding API handlers.
  await safe_cp (src "api"), (target "src/")

export default Render
