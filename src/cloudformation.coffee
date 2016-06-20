{async, first, sleep} = require "fairmont"

module.exports = async (env) ->
    {cfo} = yield require("./aws")()
    config = require("./configuration/publish")(env)

    getStack = async (id) ->
      first (yield cfo.describeStacks({StackName: id})).Stacks

    # Create the application's backend using CloudFormation.
    create: async ->
      params =
        StackName: "#{config.name}-#{env}"
        TemplateBody: config.aws.cfoTemplate
      {StackID} = yield cfo.createStack params
      StackID

    # Delete the application using CloudFormation
    delete: async ->
      name = "#{config.name}-#{env}"
      {StackId} = yield getStack name
      yield cfo.deleteStack StackName: name
      StackId

    # Confirm the stack is viable and online.
    createWait: async (id) ->
      while true
        {StackStatus} = yield getStack id
        switch StackStatus
          when "CREATE_IN_PROGRESS"
            yield sleep 5000
          when "CREATE_COMPLETE"
            return true
          else
            console.error "Stack creation failed. Aborting.", StackStatus
            throw new Error()


    # Confirm the stack is fully and properly deleted.
    deleteWait: async (id) ->
      while true
        {StackStatus} = yield getStack id
        switch StackStatus
          when "DELETE_IN_PROGRESS"
            yield sleep 5000
          when "DELETE_COMPLETE"
            return true
          else
            console.error "Stack deletion failed. Aborting.", StackStatus
            throw new Error()
