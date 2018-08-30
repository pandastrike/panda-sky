{async, first, sleep} = require "fairmont"

scan = require "./scan"
Confirm = require "./confirm"

module.exports = async (s) ->
  {cfo} = yield require("../../../index")(s.config.aws.region, s.config.profile)
  getStack = async (name) ->
    try
      first (yield cfo.describeStacks({StackName: name})).Stacks
    catch
      false
  # Confirm the stack is fully and properly deleted.
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


  {isViable} = scan s
  confirm = Confirm s

  # All of the stuff needed before we're sure it's safe to proceed.
  preDelete = async (name, options) ->
    console.error "-- Scanning AWS for appropriate Cloud resources."
    yield isViable name
    yield confirm name, options

  # This is the main domain deletion engine.
  destroy = async (name) ->
    console.error "Tearing down custom domain stack..."
    yield cfo.deleteStack StackName: s.stackName + "CustomDomain"
    yield deleteWait s.stackName + "CustomDomain"

  {preDelete, destroy}
