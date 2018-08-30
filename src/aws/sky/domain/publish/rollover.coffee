{async, empty, first, sleep} = require "fairmont"
interview = require "../../../../interview"

module.exports = async (s) ->
  {cfo} = yield require("../../../index")(s.config.aws.region, s.config.profile)
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

  deleteWait = async (name) ->
    while true
      {StackStatus, StackStatusReason} = yield getStack name
      return true if !StackStatus
      switch StackStatus
        when "DELETE_IN_PROGRESS"
          yield sleep 5000
        when "DELETE_COMPLETE"
          return true
        else
          console.warn "Stack deletion failed.", StackStatus, StackStatusReason
          return false


  needsRollover: async (name) ->
    yield getStack s.stackName + "CustomDomain"

  rollover: async (newName) ->
    [oldName] = yield s.meta.hostnames.fetch()
    yield confirmRollover newName, oldName

    console.error "Removing obsolete resources..."
    yield cfo.deleteStack StackName: s.stackName + "CustomDomain"
    yield deleteWait s.stackName + "CustomDomain"
    console.error "Applying new custom domain stack..."
    yield cfo.createStack
      StackName: s.stackName + "CustomDomain"
      TemplateURL: "https://#{s.srcName}.s3.amazonaws.com/custom-domain.yaml"
      Capabilities: ["CAPABILITY_IAM"]
      Tags: s.config.tags
    yield publishWait s.stackName + "CustomDomain"


# Explain to the developer what they're asking, and confirm they want it.
confirmRollover = async (newName, oldName, isHard) ->
  description = gracefulConfirm newName, oldName
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

gracefulConfirm = (newName, oldName) -> """
  WARNING: You are about to publish a Sky custom domain resource for
  your API endpoint.  However, there is already a custom domain in place.
  You are requesting a graceful rollover from:

    OLD
    - https://#{oldName}

    NEW
    - https://#{newName}

  This is a destructive operation.  The full publish and tear-down cycle
  will take approximately 60 minutes. Your old endpoint will not be affected
  until the new one is confirmed to be fully operational.


  Please confirm that you wish to continue. [Y/n]
  """
