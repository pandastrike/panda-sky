import renderHead from "./assets/head"
import renderBody from "./assets/body"

handler = (request, context) ->
  name = request.url.path.name || "World"
  name = name.charAt(0).toUpperCase() + name.slice(1)
  message = renderHead name
  message += renderBody name
  message

export default handler
