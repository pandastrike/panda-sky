# This module supports out-of-CFo preparation and modification to our app's
# API Gateway and all critical support services, lambdas, S3, CFr, etc.
{async, read, md5, empty, exists} = require "fairmont"
{yaml} = require "panda-serialize"
{resolve, join} = require "path"

module.exports = async (env, config) ->
  name = "#{env}-#{config.projectID}"
  bucket = yield require("./s3")(env, config, name)

  pkg = join process.cwd(), "deploy", "package.zip"
  description = join process.cwd(), "api.yaml"

  throw new Error("Unable to find deploy/package.zip") if !(yield exists pkg)
  throw new Error("Unable to find api.yaml") if !(yield exists description)

  handlers =
    isCurrent: async (remote) ->
      local = md5 yield read(pkg, "buffer")
      if local == remote.handlers then true else false

    update: async -> yield bucket.putObject "package.zip", pkg

  api =
    isCurrent: async (remote) ->
      local = md5 yield read description
      if local == remote.api then true else false

    update: async -> yield bucket.putObject "api.yaml", description

  # .sky holds the app's tracking metadata, ie hashes of API and handler defs.
  metadata =
    fetch: async ->
      if data = yield bucket.getObject ".sky"
        yaml data
      else
        false

    update: async ->
      data =
        handlers: md5 yield read(pkg, "buffer")
        api: md5 yield read description

      yield bucket.putObject(".sky", (yaml data), "text/yaml")

  # Create and/or update an S3 bucket for our app's GW deployment.  This bucket
  # is our Cloud repository for everything we need to run the core of a Mango
  # app.  It contains the source code for the GW's lambda handlers (as a zip
  # archive), the API description, and associated metadata.
  prepare = async ->
    # Determine whether an update is required or if the deployment is up-to-date.
    app = yield metadata.fetch()

    # If this is a fresh deploy.
    if !app
      console.log "No deployment detected. Preparing Panda Sky infrastructure."
      yield bucket.establish()
      yield api.update()
      yield handlers.update()
      return true

    # Compare what's in the local repository to the hashes stored in the bucket
    updates = []
    if !(yield api.isCurrent app)
      yield api.update()
      updates.push "GW"
    if !(yield handlers.isCurrent app)
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
    yield bucket.deleteObject "package.zip"
    yield bucket.destroy()

  # Return exposed functions.
  {destroy, prepare, syncMetadata}
