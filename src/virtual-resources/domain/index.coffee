import {resolve} from "path"
import Interview from "panda-interview"
import questions from "./questions"
import validate from "./validate"
import Bucket from "../bucket"
import Templater from "../../templater"

Stack = class Stack
  constructor: (@config) ->
    @cache = @config.aws.cache
    @sundog = @config.sundog
    @stack = @config.aws.stack
    @name = @stack.name + "-CustomDomain"
    @cfo = @sundog.CloudFormation
    @acm = @sundog.ACM "us-east-1" #quirk of how sky uses ACM.
    @route53 = @sundog.Route53
    @s3 = @sundog.S3

  initialize: ->
    @bucket = await Bucket @config
    await validate @config, @bucket

  # Ask politely if a stack override is neccessary.
  confirm: (action, domain) ->
    try
      {ask} = new Interview()
      answers = await ask questions action, domain
    catch e
      console.warn "Process aborted."
      console.log "Done."
      process.exit()

    if answers.continue
      return
    else
      console.warn "Discontinuing custom domain operation."
      console.log "Done."
      process.exit()

  publish: ->
    await @prepare()
    await @confirm "publish", "https://#{@config.aws.hostnames[0]}"
    console.log "Publishing custom domain..."
    if await @cfo.get @name
      await @cfo.update @cloudformationParameters
    else
      await @cfo.create @cloudformationParameters

  delete: ->
    await @confirm "delete", "https://#{@config.aws.hostnames[0]}"
    console.log "Deleting custom domain stack..."
    await @cfo.delete @name

  # Render the custom domain CloudFormation template.
  prepare: ->
    {endpoint} = @bucket.metadata
    endpoint = endpoint.split("/#{@config.env}")[0]
    endpoint = endpoint.split("://")[1]

    @cache.endpoint = endpoint
    @cache.hostedzone = await @route53.hzGet @config.aws.hostnames[0]
    @cache.certificate = await @acm.fetch @config.aws.hostnames[0]
    @cache.api = await @cfo.output "API", @stack.name
    @config.aws.cache = @cache

    # Render the custom domain stack.
    path = resolve __dirname, "..", "..", "..", "..", "..", "templates", "custom-domain.yaml"
    template = await Templater.read path
    stack = template.render @config

    # Prepare the CloudFormation parameters for publishing.
    @cloudformationParameters =
      StackName: @name
      TemplateURL: "https://#{@stack.src}.s3.amazonaws.com/custom-domain.yaml"
      Capabilities: ["CAPABILITY_IAM"]
      Tags: @config.tags

    # Upload to the orchestation bucket.
    await @s3.put @stack.src, "custom-domain.yaml", stack, "text/yaml"

    # Make sure the log bucket exists.
    await @s3.bucketTouch @cache.logBucket


stack = (config) ->
  S = new Stack config
  await S.initialize()
  S

export default stack
