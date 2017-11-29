{async, md5, read, keys, cat, empty, min} = require "fairmont"
{yaml} = require "panda-serialize"

module.exports = (s) ->
  handlers =
    isCurrent: async (remote) ->
      local = md5 yield read(s.pkg, "buffer")
      if local == remote.handlers then true else false

    update: async -> yield s.bucket.putObject "package.zip", s.pkg
    tier: 1

  api =
    isCurrent: async (remote) ->
      local = md5 yield read s.apiDef
      if local == remote.api then true else false

    update: async -> yield s.bucket.putObject "api.yaml", s.apiDef
    tier: 1

  skyConfig =
    isCurrent: async (remote) ->
      local = md5 yield read s.skyDef
      if local == remote.sky then true else false

    update: async -> yield s.bucket.putObject "sky.yaml", s.skyDef
    tier: 0

  # .sky holds the app's tracking metadata, ie hashes of API and handler defs.
  # this is how we determine what's currently deployed.  It's only updated
  # if we successfully complete a publish.
  current =
    fetch: async ->
      try
        yaml yield s.bucket.getObject ".sky"
      catch e
        false

    update: async ->
      data =
        api: md5 yield read s.apiDef
        handlers: md5 yield read(s.pkg, "buffer")
        sky: md5 yield read s.skyDef

      yield s.bucket.putObject(".sky", (yaml data), "text/yaml")

    check: async (meta) ->
      updates = []
      yield updates.push handlers.tier if !yield handlers.isCurrent meta
      yield updates.push api.tier if !yield api.isCurrent meta
      yield updates.push skyConfig.tier if !yield skyConfig.isCurrent meta
      if empty updates then -1 else min updates

  template =
    # Sky stores the CloudFormation template that describes the infrastructure
    # stack. For some updates, Sky needs to make intermediate templates that # deletes some resources and then puts back updated versions of all.
    # Assign tiers to resources so we can specify how bare the intermediate
    # template needs to be.
    update: async ->
      tiers = keys s.resources

      intermediate = (tier, template) ->
        retain = cat (r for k, r of s.resources when k <= tier)...
        R = template.Resources
        delete R[k] for k, v of R when !(k in retain)
        template.Resources = R
        template

      t = full: JSON.parse s.config.aws.cfoTemplate
      t[x] = JSON.parse s.config.aws.cfoTemplate for x in tiers

      write = async (name, file) ->
        yield s.bucket.putObject name, (yaml file), "text/yaml"

      yield write "template.yaml", t.full
      yield write "template-#{x}.yaml", (intermediate x, t[x]) for x in tiers

  update = async ->
    yield api.update()
    yield skyConfig.update()
    yield handlers.update()
    yield template.update()

  create = async ->
    yield s.bucket.establish()
    yield update()

  destroy = async ->
    if yield s.bucket.exists()
      console.error "-- Deleting deployment metadata."
      erase = async (name) -> yield s.bucket.deleteObject name
      yield erase object for object in yield s.bucket.listObjects()
      yield s.bucket.destroy()
    else
      console.error "WARNING: No Sky metadata detected for this deployment."

  {
    handlers
    api
    skyConfig
    template
    current
    update
    create
    delete: destroy
  }
