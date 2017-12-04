{async} = require "fairmont"
interview = require "../../../../interview"

# Determine the kind of confirmation message we should show to the developer.
module.exports = (s) ->
  async (name, options) ->
    if !yield s.cfr.get name
      yield showPrompt msg.publish name if !options.yes
    else
      if yield s.cfr.needsUpdate name
        yield showPrompt msg.update name if !options.yes
      else
        console.error msg.noop name
        process.exit()


showPrompt = async (description) ->
  interview.setup()
  questions = [
    name: "confirm"
    description: description
    default: "n"
  ]

  answers = yield interview.ask questions
  if !answers.confirm
    console.error "Discontinuing custom domain publish."
    console.error "Done."
    process.exit()

msg =
  publish: (name) -> """
    WARNING: You are about to publish a Sky custom domain resource for
    your API endpoint.  This will deploy a CloudFront distribution at:

      - https://#{name}

    This deploy will take approximately 30 minutes to complete.


    Please confirm that you wish to continue. [Y/n]
  """

  update: (name) -> """
    WARNING: You are about to update a Sky custom domain resource for
    your API endpoint.  This will update the CloudFront distribution at:

      - https://#{name}

    This update will take approximately 30 minutes to complete.


    Please confirm that you wish to continue. [Y/n]
  """

  noop: (name) -> """
    WARNING: You requested an update for the Sky custom domain resource at

      - https://#{name}

    But this resource appears to be up to date.  There is nothing to change.
    This operation will discontinue.
    Done.
  """
