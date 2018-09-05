import Interview from "panda-interview"
import validate from "./validate"
import Bucket from "../bucket"
import Handlers from "../handlers"
import questions from "./questions"

Stack = class Stack
  constructor: (@config) ->
    @sundog = @config.sundog
    @stack = @config.aws.stack
    @cfo = @sundog.CloudFormation
    @eni = @sundog.EC2.ENI

  initialize: ->
    await validate @config
    @bucket = await Bucket @config
    @handlers = await Handlers @config


  delete: ->
    if @config.aws.vpc?.skipConnectionDraining
      await @eni.purge @bucket.subnetIDs,
        (eni) -> ///#{stack.name}///.test eni.RequesterId
    await @cfo.delete stack.name
    await @bucket.delete()

  getEndpoint: ->
    id = await @cfo.output "API", @stack.name
    "https://#{id}.execute-api.#{@config.aws.region}.amazonaws.com/#{@config.env}"

  getSubnets: -> (await @cfo.output "Subnets", name).split ","

  # Ask politely if a stack override is neccessary.
  override: ->
    try
      {ask} = new Interview()
      answers = await ask questions @stack.name
    catch e
      console.warn "Process aborted."
      console.log "Done."
      process.exit()

    if answers.override
      console.log "Attempting to remove non-Sky stack..."
      await @cfo.delete @stack.name
      console.log "Removal complete.  Continuing with publish."
    else
      console.warn "Discontinuing publish."
      console.log "Done."
      process.exit()

  newPublish: ->
    console.log "Waiting for new stack publish to complete..."
    await @bucket.create()
    await @cfo.create @bucket.cloudformationParameters
    await @bucket.syncState await @getEndpoint()

  updatePublish: ->
    {dirtyAPI, dirtyLambda} = await @bucket.needsUpdate()
    if !dirtyAPI && !dirtyLambda
      console.warn "The Sky deployment is already up to date."
      return

    @bucket.sync()
    if dirtyAPI
      console.log "Waiting for stack update to complete..."
      await @cfo.update @bucket.cloudformationParameters
    if dirtyLambda
      console.log "Updating deployment lambdas..."
      await @handlers.update()
    await @bucket.syncState await @getEndpoint()

  publish: ->
    if @bucket.metadata
      await @updatePublish()
    else
      await @override() if (await @cfo.get @stack.name)
      await @newPublish()
    console.log "Your API is online and ready at the following endpoint:"
    console.log "  #{await @getEndpoint()}"

stack = (config) ->
  S = new Stack config
  await S.initialize()
  S

export default stack
