{async, empty} = require "fairmont"
scan = require "./scan"

module.exports = (s) ->
  {scan} = scan s

  # Write out a CloudFormation description configuration on demand.
  config = (tier) ->
    if tier == "full"
      t = "template.yaml"
    else
      t = "template-#{tier}.yaml"

    StackName: s.stackName
    TemplateURL: "http://#{s.srcName}.s3.amazonaws.com/#{t}"
    Capabilities: ["CAPABILITY_IAM"]
    Tags: s.config.tags

  updateLambdas = async (dirtyHandlers) ->
    console.error "Checking Lambda code..."
    if dirtyHandlers
      console.error "Lambdas out of date. pushing changes..."
      yield s.lambdas.update()
      console.error "Done."
    else
      console.error "Lambdas are current."

  publish = async ->
    console.error "-- Scanning AWS for current deploy."
    {dirtyTier, dirtyHandlers} = yield scan()  # Prep the app's core bucket
    if dirtyTier == -1
      console.error "#{s.stackName} infrastructure is up to date."
      yield updateLambdas dirtyHandlers

      return false

    # If the stack already exists, update instead of create.
    if yield s.cfo.get()
      yield s.cfo.update (config dirtyTier), (config "full")
    else
      yield s.cfo.create config "full"
    true

  # Handle stuff that happens after we've confirmed the stack deployed.
  postPublish = async ->
    yield s.meta.current.update yield s.cfo.getApiUrl()
    if !s.config.aws.environments[s.env].cache
      console.error "Your API is online and ready at the following endpoint:"
      console.error "  #{yield s.cfo.getApiUrl()}"

  # Handle stuff that happens after we've confirmed the stack deleted.
  postDelete = async ->
    yield s.meta.delete()
    console.log s.config.aws.vpc
    if s.config.aws.vpc?.skipConnectionDraining
      yield s.lambdas.delete()

  {publish, postPublish, postDelete}
