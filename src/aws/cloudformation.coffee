{async, first, sleep, min} = require "fairmont"
SkyStack = require "./sky"

module.exports = async (env, config) ->
    {cfo} = yield require("./index")(config.aws.region)
    sky = yield SkyStack env, config
    console.log JSON.stringify(sky, null, 2)
    process.exit()
    name = "#{config.name}-#{env}"

    getStack = async (id) ->
      try
        first (yield cfo.describeStacks({StackName: id})).Stacks
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
    update = async (dirtyTier) ->
      console.error "-- Update required."
      # Because of GW quirk, all API resources have to be wiped out before
      # making edits to child resources. Updating is a two-step process.
      # Step 1: Destroy guts of Stack
      console.error "-- Removing obsolete resources."
      yield cfo.updateStack sky.stack.makeConfig dirtyTier
      yield publishWait name

      # Step 2: Apply the full, updated Stack. Put it all back.
      console.error "-- Waiting for publish to complete."
      yield cfo.updateStack sky.stack.makeConfig "full"

    # Create a new stack from scrath with the template.
    create = async ->
      console.error "-- Waiting for publish to complete."
      yield cfo.createStack sky.stack.makeConfig "full"

    publish = async ->
      console.error "-- Scanning AWS for current deploy."
      dirtyTier = yield sky.stack.scan()  # Prep the app's core bucket
      if update == -1
        console.error "#{name} is up to date."
        return false

      # If the stack already exists, update instead of create.
      if {StackId} = yield getStack name
        yield update dirtyTier
      else
        {StackId} = yield create()
      StackId

    # Delete the application using CloudFormation
    destroy = async ->
      {StackId} = yield getStack name
      yield cfo.deleteStack StackName: name
      StackId

    # Confirm the stack is viable and online.
    publishWait = async (id) ->
      while true
        {StackStatus, StackStatusReason} = yield getStack id
        switch StackStatus
          when "CREATE_IN_PROGRESS", "UPDATE_IN_PROGRESS", "UPDATE_COMPLETE_CLEANUP_IN_PROGRESS"
            yield sleep 5000
          when "CREATE_COMPLETE", "UPDATE_COMPLETE"
            return true
          else
            error = new Error "Stack creation failed. #{StackStatus} #{StackStatusReason}"
            throw error


    # Confirm the stack is fully and properly deleted.
    deleteWait = async (id) ->
      while true
        s = yield getStack id
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

    # Handle stuff that happens after we've confirmed the stack deployed.
    postPublish = async ->
      yield src.syncMetadata()
      if !config.aws.environments[env].cache
        console.error "Your API is online and ready at the following endpoint:"
        console.error "  #{yield getApiUrl()}"


    # Handle stuff that happens after we've confirmed the stack deleted.
    postDelete = async -> yield src.destroy()


    {
      publish
      delete: destroy
      publishWait
      deleteWait
      postPublish
      postDelete
      getApiUrl
    }
