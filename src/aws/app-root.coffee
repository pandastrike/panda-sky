# This module supports out-of-CFo preparation and modification to our app's
# API Gateway and all critical support services, lambdas, S3, CFr, etc.
{async, read, md5, empty, exists} = require "fairmont"
{yaml} = require "panda-serialize"
{resolve, join} = require "path"

module.exports = async (appRoot, env, config) ->
  name = "#{env}-#{config.projectID}"
  bucket = yield require("./s3")(env, config, name)
  lambda = yield require("./lambda")(config)

  pkg = join appRoot, "deploy", "package.zip"
  apiDef = join appRoot, "api.yaml"
  skyDef = join appRoot, "sky.yaml"

  throw new Error("Unable to find #{appRoot}/deploy/package.zip") if !(yield exists pkg)
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


  template =
    update: async ->
      # Sky stores the CloudFormation template that describes the infrastructure
      # stack. For updates to Gateway with nested methods/resources, Sky needs
      # to make intermediate templates that deletes all methods and then puts
      # everything back with updates.
      _empty = (template) ->
        retain = ["API"]
        R = template.Resources
        delete R[k] for k, v of R when !(k in retain)
        template.Resources = R
        template

      hard = (template) ->
        retain = ["API", "LambdaRole", "CFRDistro", "DNSRecords"]
        R = template.Resources
        delete R[k] for k, v of R when !(k in retain) && !k.match(/^Mixin/)
        template.Resources = R
        template

      soft = (template) ->
        retain = ["API", "LambdaRole", "Deployment", "CFRDistro", "DNSRecords"]
        R = template.Resources
        delete R[k] for k, v of R when !(k in retain) && !k.match(/^Mixin/)
        R.Deployment.DependsOn = []
        template.Resources = R
        template

      t = JSON.parse config.aws.cfoTemplate
      t2 = JSON.parse config.aws.cfoTemplate
      t3 = JSON.parse config.aws.cfoTemplate
      console.error "Uploading hard, soft, etc. templates to s3"
      yield bucket.putObject "template.yaml", (yaml t), "text/yaml"
      yield bucket.putObject "empty-template.yaml", (yaml _empty t), "text/yaml"
      yield bucket.putObject "hard-template.yaml", (yaml hard t2), "text/yaml"
      yield bucket.putObject "soft-template.yaml", (yaml soft t3), "text/yaml"
      console.error "Finished template uploads"



  # Create and/or update an S3 bucket for our app's GW deployment.  This bucket
  # is our Cloud repository for everything we need to run the core of a Mango
  # app.  It contains the source code for the GW's lambda handlers (as a zip
  # archive), the API description, and associated metadata.
  prepare = async ->
    # Determine whether an update is required or if the deployment is up-to-date.
    console.error "Fetching metadata"
    app = yield metadata.fetch()

    # If this is a fresh deploy.
    if !app
      console.error "No deployment detected. Preparing Panda Sky infrastructure."
      yield bucket.establish()
      yield api.update()
      yield skyConfig.update()
      yield handlers.update()
      yield template.update()
      return true

    # Compare what's in the local repository to the hashes stored in the bucket
    updates = []
    console.error "updating templates in S3"
    yield template.update()
    console.error "check for current app-ness"
    if !(yield skyConfig.isCurrent app)
      console.error "sky config update"
      yield skyConfig.update()
      updates.push "All"
    if !(yield api.isCurrent app)
      console.error "api update"
      yield api.update()
      updates.push "GW"
    if !(yield handlers.isCurrent app)
      console.error "handlers update"
      yield handlers.update()
      updates.push "Lambda"

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
    yield bucket.deleteObject ".sky"
    yield bucket.deleteObject "api.yaml"
    yield bucket.deleteObject "sky.yaml"
    yield bucket.deleteObject "template.yaml"
    yield bucket.deleteObject "soft-template.yaml"
    yield bucket.deleteObject "hard-template.yaml"
    yield bucket.deleteObject "empty-template.yaml"
    yield bucket.deleteObject "package.zip"
    yield bucket.destroy()

  lambdaUpdate = async (names, bucket) ->
    republish = ->
      lambda.update(name, bucket, "package.zip") for name in names

    yield handlers.update()
    yield Promise.all(republish())

  # Return exposed functions.
  {destroy, lambdaUpdate, prepare, syncMetadata}
