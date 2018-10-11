import coffee from "./coffee"
import javascript from "./javascript"
import passthru from "./pass-thru"

transpile = (source, target) ->
  await coffee source, target
  await javascript source, target
  await passthrough source, target

export default transpile
