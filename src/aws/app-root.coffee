# This module supports out-of-CFo preparation and modification to our app's
# API Gateway and all critical support services, lambdas, S3, CFr, etc.
{async, read, md5, empty, exists, cat, length, keys} = require "fairmont"
{yaml} = require "panda-serialize"
{resolve, join} = require "path"

module.exports = async (env, config) ->
  stackName = "#{config.name}-#{env}"
  name = "#{env}-#{config.projectID}"
  bucket = yield require("./s3")(env, config, name)
  lambda = yield require("./lambda")(config)

  pkg = join process.cwd(), "deploy", "package.zip"
  apiDef = join process.cwd(), "api.yaml"
  skyDef = join process.cwd(), "sky.yaml"

  throw new Error("Unable to find deploy/package.zip") if !(yield exists pkg)
  throw new Error("Unable to find api.yaml") if !(yield exists apiDef)
  throw new Error("Unable to find sky.yaml") if !(yield exists skyDef)

  handlers =
    isCurrent: async (remote) ->
      local = md5 yield read(pkg, "buffer")
      if local == remote.handlers then true else false

    update: async -> yield bucket.putObject "package.zip", pkg

  api =
    isCurrent: async (remote) ->
      local = md5 yield read apiDef
      if local == remote.api then true else false

    update: async -> yield bucket.putObject "api.yaml", apiDef

  skyConfig =
    isCurrent: async (remote) ->
      local = md5 yield read skyDef
      if local == remote.sky then true else false

    update: async -> yield bucket.putObject "sky.yaml", skyDef

  # .sky holds the app's tracking metadata, ie hashes of API and handler defs.
  metadata =
    fetch: async ->
      if data = yield bucket.getObject ".sky"
        yaml data
      else
        false

    update: async ->
      data =
        api: md5 yield read apiDef
        handlers: md5 yield read(pkg, "buffer")
        sky: md5 yield read skyDef


      yield bucket.putObject(".sky", (yaml data), "text/yaml")


  resources =
    0: ["API", "LambdaRole"]
    1: ["DNSRecords"]

  template =
    update: async ->
      # Sky stores the CloudFormation template that describes the infrastructure
      # stack. For some updates, Sky needs to make intermediate templates that # deletes some resources and then puts back updated versions of all.
      # Assign tiers to resources so we can specify how bare the intermediate
      # template needs to be.
      tiers = keys resources

      intermediate = (tier, template) ->
        retain = cat (r for k, r of resources when k <= tier)...
        R = template.Resources
        delete R[k] for k, v of R when !(k in retain)
        template.Resources = R
        template

      t = full: JSON.parse config.aws.cfoTemplate
      t[x] = JSON.parse config.aws.cfoTemplate for x in tiers

      write = async (name, file) ->
        yield bucket.putObject name, (yaml file), "text/yaml"

      yield write "template.yaml", t.full
      yield write "template-#{x}.yaml", (intermediate x, t[x]) for x in tiers

  stackConfig = (tier) ->
    if tier == "full"
      t = "template.yaml"
    else
      t = "template-#{tier}.yaml"

    StackName: stackName
    TemplateURL: "http://#{env}-#{config.projectID}.s3.amazonaws.com/#{t}"
    Capabilities: ["CAPABILITY_IAM"]
    Tags: config.tags




  # Create and/or update an S3 bucket for our app's GW deployment.  This bucket
  # is our Cloud repository for everything we need to run the core of a Sky
  # app.  It contains the source code for the GW's lambda handlers (as a zip
  # archive), the API description, and associated metadata.
  scanDeployment = async ->
    # Determine whether an update is required or if the deployment is up-to-date.
    app = yield metadata.fetch()

    # If this is a fresh deploy.
    if !app
      console.error "-- No deployment detected. Preparing Panda Sky infrastructure."
      yield bucket.establish()
      yield api.update()
      yield skyConfig.update()
      yield handlers.update()
      yield template.update()
      return true

    # Compare what's in the local repository to the hashes stored in the bucket
    updates = []
    console.error "-- Existing deployment detected."
    yield template.update()
    if !(yield skyConfig.isCurrent app)
      yield skyConfig.update()
      updates.push 0
    if !(yield api.isCurrent app)
      yield api.update()
      updates.push 1
    if !(yield handlers.isCurrent app)
      yield handlers.update()
      updates.push 1

    if empty updates
      return false
    else
      return updates

  # Once we've confirmed a successful create / update, we need to update the
  # metadata for the app's bucket.  Those hashes will allow us to compare
  # against future publish requests.
  syncMetadata = async -> yield metadata.update()

  # Remove the bucket and all associated
  destroy = async ->
    erase = async (name) -> yield bucket.deleteObject name
    yield erase ".sky"
    yield erase "api.yaml"
    yield erase "sky.yaml"
    yield erase "package.zip"

    yield erase "template.yaml"
    yield erase "template-#{x}.yaml" for x in keys resources

    yield bucket.destroy()

  lambdaUpdate = async (names, bucket) ->
    republish = ->
      lambda.update(name, bucket, "package.zip") for name in names

    yield handlers.update()
    yield Promise.all(republish())

  # Return exposed functions.
  {destroy, lambdaUpdate, scanDeployment, syncMetadata, stackConfig}
