{async} = require "fairmont"
interview = require "../../../../interview"

module.exports = (s) ->
  async ->
    interview.setup()
    questions = [
      name: "confirm"
      description: """
        WARNING: You are about to publish a Sky custom domain resource for
        your API endpoint.  This will deploy a CloudFront distribution at:

          - https://#{s.config.aws.hostnames[0]}

        This deploy will take approximately 30 minutes to complete.


        Please confirm that you wish to continue. [Y/n]
      """
      default: "n"
    ]

    answers = yield interview.ask questions
    if !answers.confirm
      console.error "Discontinuing custom domain publish."
      console.error "Done."
      process.exit()
