{resolve} = require "path"
{async, clone, merge, sleep, first} = require "fairmont"

scan = require "./scan"
Confirm = require "./confirm"
Rollover = require "./rollover"

Templater = require "../../../../templater"


module.exports = async (s) ->
  {cfo} = yield require("../../../index")(s.config.aws.region, s.config.profile)
  {isViable} = scan s
  confirm = Confirm s
  {rollover, needsRollover} = yield Rollover s

  getStack = async (name) ->
    try
      first (yield cfo.describeStacks({StackName: name})).Stacks
    catch
      false

  # Confirm the stack is viable and online.
  publishWait = async (name) ->
    while true
      {StackStatus, StackStatusReason} = yield getStack name
      switch StackStatus
        when "CREATE_IN_PROGRESS", "UPDATE_IN_PROGRESS", "UPDATE_COMPLETE_CLEANUP_IN_PROGRESS"
          yield sleep 5000
        when "CREATE_COMPLETE", "UPDATE_COMPLETE"
          return true
        else
          error = new Error "Stack creation failed. #{StackStatus} #{StackStatusReason}"
          throw error

  # All of the stuff needed before we're sure it's safe to proceed.
  prePublish = async (name, options) ->
    console.error "-- Scanning AWS for appropriate Cloud resources."
    yield isViable name
    yield uploadTemplate name

    if yield needsRollover name
      return yield rollover name, options
    yield confirm name, options
    console.error "Publishing..."
    yield publish name

  # This is the main domain publishing engine.
  publish = async (name) ->
    console.error "Publishing custom domain stack..."
    yield cfo.createStack
      StackName: s.stackName + "CustomDomain"
      TemplateURL: "https://#{s.srcName}.s3.amazonaws.com/custom-domain.yaml"
      Capabilities: ["CAPABILITY_IAM"]
      Tags: s.config.tags
    yield publishWait s.stackName + "CustomDomain"

  uploadTemplate = async (name) ->
    # Get the final configuration that needs to be pulled from network calls:
    {endpoint} = yield s.meta.current.fetch()
    endpoint = endpoint.split("/#{s.env}")[0]
    endpoint = endpoint.split("://")[1]
    s.config.aws.cache.endpoint = endpoint

    s.config.aws.cache.hostedzone =
      yield s.route53.getHostedZoneID name

    s.config.aws.cache.certificate = yield s.acm.fetch name

    # Render and upload the custom domain stack to the orchestration bucket.
    path = resolve __dirname, "..", "templates", "custom-domain.yaml"
    template = yield Templater.read path
    stack = template.render s.config
    yield s.bucket.putObject "custom-domain.yaml", stack, "text/yaml"


  {prePublish, publish}
