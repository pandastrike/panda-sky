handler = (request, context) ->
  name = request.url.path.name || "World"
  name = name.charAt(0).toUpperCase() + name.slice(1)
  "Hello, #{name}!"

export default handler
