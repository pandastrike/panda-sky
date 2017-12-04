{async} = require "fairmont"
interview = require "../../../../interview"

# Determine the kind of confirmation message we should show to the developer.
module.exports = (s) ->
  async (name, options) ->
    yield showPrompt msg.invalidate name if !options.yes

showPrompt = async (description) ->
  interview.setup()
  questions = [
    name: "confirm"
    description: description
    default: "n"
  ]

  answers = yield interview.ask questions
  if !answers.confirm
    console.error "Discontinuing custom domain invalidation."
    console.error "Done."
    process.exit()

msg =
  invalidate: (name) -> """
    WARNING: You are about to invalidate the edge cache for the Sky custom
    domain resource at:

      - https://#{name}

    This will take 5-15 minutes to propogate across the edge server infrastructure.


    Please confirm that you wish to continue. [Y/n]
  """
