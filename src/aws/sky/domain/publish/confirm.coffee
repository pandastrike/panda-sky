{async} = require "fairmont"
interview = require "../../../../interview"

# Determine the kind of confirmation message we should show to the developer.
module.exports = (s) ->
  async ->
    if !yield s.cfr.get s.config.aws.hostnames[0]
      yield showPrompt msg.publish s
    else
      if yield s.cfr.needsUpdate s.config.aws.hostnames[0]
        yield showPrompt msg.update s
      else
        console.error msg.noop s
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
  publish: (s) -> """
    WARNING: You are about to publish a Sky custom domain resource for
    your API endpoint.  This will deploy a CloudFront distribution at:

      - https://#{s.config.aws.hostnames[0]}

    This deploy will take approximately 30 minutes to complete.


    Please confirm that you wish to continue. [Y/n]
  """

  update: (s) -> """
    WARNING: You are about to update a Sky custom domain resource for
    your API endpoint.  This will update the CloudFront distribution at:

      - https://#{s.config.aws.hostnames[0]}

    This update will take approximately 30 minutes to complete.


    Please confirm that you wish to continue. [Y/n]
  """

  noop: (s) -> """
    WARNING: You requested an update for the Sky custom domain resource at

      - https://#{s.config.aws.hostnames[0]}

    But this resource appears to be up to date.  There is nothing to change.
    This operation will discontinue.
    Done.
  """
