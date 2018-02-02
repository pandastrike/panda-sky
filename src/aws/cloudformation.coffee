{async, first, sleep, cat, collect, select} = require "fairmont"
SkyStack = require "./sky"

module.exports = async (env, config, name) ->
    {cfo} = yield require("./index")(config.aws.region)

    get = async ->
      try
        first (yield cfo.describeStacks({StackName: name})).Stacks
      catch
        false

    getResource = async (LogicalResourceId, StackName) ->
      data = yield cfo.describeStackResource {LogicalResourceId, StackName}
      data.StackResourceDetail.PhysicalResourceId

    buildEndpointURL = (id, env) ->
      "https://#{id}.execute-api.#{config.aws.region}.amazonaws.com/#{env}"

    getApiUrl = async ->
      apiID = yield getResource "API", name
      buildEndpointURL apiID, env

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

    list = async (current=[], token) ->
      params =
        StackStatusFilter: [ "CREATE_IN_PROGRESS", "CREATE_COMPLETE", "ROLLBACK_IN_PROGRESS", "ROLLBACK_FAILED", "ROLLBACK_COMPLETE", "DELETE_IN_PROGRESS", "UPDATE_IN_PROGRESS", "UPDATE_COMPLETE_CLEANUP_IN_PROGRESS", "UPDATE_COMPLETE", "UPDATE_ROLLBACK_IN_PROGRESS", "UPDATE_ROLLBACK_FAILED", "UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS", "UPDATE_ROLLBACK_COMPLETE"]
      params.NextToken = token if token

      {NextToken, StackSummaries} = yield cfo.listStacks params
      if NextToken
        yield list cat(current, StackSummaries), NextToken
      else
        cat current, StackSummaries

    # Get all stacks with the project name in their prefix.
    search = async (projectName) ->
      query = ({StackName}) -> ///^#{projectName}-.+$///.test StackName
      getEnv = (StackName) ->
        match = ///^#{projectName}-(.*)$///.exec StackName
        match[1]

      stacks = collect select query, yield list()
      for {StackName, StackStatus} in stacks
        apiID = yield getResource "API", StackName
        env = getEnv StackName
        url = buildEndpointURL apiID, env
        {env, url, status:StackStatus}


    {
      get
      getApiUrl
      create
      update
      delete: destroy
      publishWait
      deleteWait
      search
    }
