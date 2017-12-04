{async} = require "fairmont"
interview = require "../../../../interview"

# Determine the kind of confirmation message we should show to the developer.
module.exports = (s) ->
  async (name, options) ->
    yield showPrompt msg.update name if !options.yes


showPrompt = async (description) ->
  interview.setup()
  questions = [
    name: "confirm"
    description: description
    default: "n"
  ]

  answers = yield interview.ask questions
  if !answers.confirm
    console.error "Discontinuing custom domain delete."
    console.error "Done."
    process.exit()

msg =
  update: (name) -> """
    WARNING: You are about to delete a Sky custom domain resource for
    your API endpoint.  This will remove the CloudFront distribution at:

      - https://#{name}

    This is a destructive operation and will take approximately 30 minutes to complete.


    Please confirm that you wish to continue. [Y/n]
  """
