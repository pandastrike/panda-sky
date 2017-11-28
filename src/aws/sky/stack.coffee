{async, empty} = require "fairmont"
module.exports = (s) ->
  # Write out a CloudFormation description configuration on demand.
  makeConfig: (tier) ->
    if tier == "full"
      t = "template.yaml"
    else
      t = "template-#{tier}.yaml"

    StackName: s.stackName
    TemplateURL: "http://#{s.env}-#{s.config.projectID}.s3.amazonaws.com/#{t}"
    Capabilities: ["CAPABILITY_IAM"]
    Tags: s.config.tags

  # Determine whether an update is required or if the deployment is up-to-date.
  scan: async ->
    app = yield s.meta.current.fetch()
    if !app
      console.error "-- No deployment detected. New deployment."
      return yield s.meta.create()

    console.error "-- Existing deployment detected."
    yield s.meta.current.check app
