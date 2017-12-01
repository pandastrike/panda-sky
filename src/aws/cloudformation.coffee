{async, first, sleep, min} = require "fairmont"
SkyStack = require "./sky"

module.exports = async (env, config, name) ->
    {cfo} = yield require("./index")(config.aws.region)

    get = async ->
      try
        first (yield cfo.describeStacks({StackName: name})).Stacks
      catch
        false

    getApiUrl = async ->
      params =
        LogicalResourceId: "API"
        StackName: name

      data = yield cfo.describeStackResource params
      apiID = data.StackResourceDetail.PhysicalResourceId
      "https://#{apiID}.execute-api.#{config.aws.region}.amazonaws.com/#{env}"

    # Update an existing stack with a new template.
    update = async (intermediateTemplate, fullTemplate) ->
      console.error "-- Update required."
      # Because of GW quirk, all API resources have to be wiped out before
      # making edits to child resources. Updating is a two-step process.
      # Step 1: Destroy guts of Stack
      if intermediateTemplate
        console.error "-- Removing obsolete resources."
        yield cfo.updateStack intermediateTemplate
        yield publishWait()

      # Step 2: Apply the full, updated Stack. Put it all back.
      console.error "-- Waiting for publish to complete."
      yield cfo.updateStack fullTemplate

    # Create a new stack from scrath with the template.
    create = async (template) ->
      console.error "-- Waiting for publish to complete."
      yield cfo.createStack template

    # Delete the application using CloudFormation
    destroy = async ->
      return false if !yield get()
      yield cfo.deleteStack StackName: name
      return true

    # Confirm the stack is viable and online.
    publishWait = async ->
      while true
        {StackStatus, StackStatusReason} = yield get()
        switch StackStatus
          when "CREATE_IN_PROGRESS", "UPDATE_IN_PROGRESS", "UPDATE_COMPLETE_CLEANUP_IN_PROGRESS"
            yield sleep 5000
          when "CREATE_COMPLETE", "UPDATE_COMPLETE"
            return true
          else
            error = new Error "Stack creation failed. #{StackStatus} #{StackStatusReason}"
            throw error


    # Confirm the stack is fully and properly deleted.
    deleteWait = async ->
      while true
        s = yield get()
        return true if !s
        switch s.StackStatus
          when "DELETE_IN_PROGRESS"
            yield sleep 5000
          when "DELETE_COMPLETE"
            return true
          else
            console.warn "Stack deletion failed.", s.StackStatus,
              s.StackStatusReason
            return false

    {
      get
      getApiUrl
      create
      update
      delete: destroy
      publishWait
      deleteWait
    }
