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

  purgeENIs = async ->
    # For deployments that interface with a VPC, and the developer has opted out of waiting for connection draining, we need to wipe out the Lambda's ENIs by force
    if s.config.aws.vpc?.skipConnectionDraining
      console.error "Destroying Lambda ENIs to speed operation. One moment..."
      yield s.eni.purge()

  publish = async ->
    console.error "-- Scanning AWS for current deploy."
    dirtyTier = yield scan()  # Prep the app's core bucket
    if dirtyTier == -1
      console.error "#{s.stackName} is up to date."
      return false

    # If the stack already exists, update instead of create.
    if yield s.cfo.get()
      yield purgeENIs()
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

  _delete = async ->
    yield purgeENIs()
    yield s.cfo.delete()

  # Handle stuff that happens after we've confirmed the stack deleted.
  postDelete = async -> yield s.meta.delete()

  {publish, postPublish, delete:_delete, postDelete}
