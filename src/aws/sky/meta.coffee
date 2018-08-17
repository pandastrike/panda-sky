{async, md5, read, keys, cat, empty, min, remove, toJSON, clone} = require "fairmont"
{yaml} = require "panda-serialize"

module.exports = (s) ->
  api =
    isCurrent: async (remote) ->
      local = md5 yield read s.apiDef
      if local == remote.api then true else false

    update: async -> yield s.bucket.putObject "api.yaml", s.apiDef
    tier: 1

  handlers =
    isCurrent: async (remote) ->
      local = md5 yield read(s.pkg, "buffer")
      if local == remote.handlers then true else false

    update: async -> yield s.bucket.putObject "package.zip", s.pkg
    tier: null

  skyConfig =
    isCurrent: async (remote) ->
      local = md5 yield read s.skyDef
      if local == remote.sky then true else false

    update: async -> yield s.bucket.putObject "sky.yaml", s.skyDef
    tier: 0

  permissions =
    isCurrent: (remote) ->
      local = md5 toJSON s.permissions
      if local == remote.permissions then true else false

    update: async -> yield s.bucket.putObject "permissions.json", toJSON(s.permissions), "text/json"
    tier: 1

  substacks =
    update: async ->
      for key, stack of s.config.aws.coreStacks
        yield s.bucket.putObject "templates/#{key}", stack, "text/yaml"

  hostnames = do ->
    fetch = async ->
      try
        data = yaml yield s.bucket.getObject "hostnames.yaml"
        data.hostnames
      catch e
        []

    add = async (name) ->
      data = yield fetch()
      data.push name
      data = hostnames: data
      yield s.bucket.putObject("hostnames.yaml", (yaml data), "text/yaml")

    _remove = async (name) ->
      data = yield fetch()
      data = remove data, name
      data = hostnames: data

      if yield s.bucket.exists()
        yield s.bucket.putObject("hostnames.yaml", (yaml data), "text/yaml")
      else
        console.log "WARNING: No Sky metadata detected for #{s.env}. Skipping."

    {fetch, add, remove: _remove}

  template =
    # Sky stores the CloudFormation template that describes the infrastructure
    # stack. For some updates, Sky needs to make intermediate templates that # deletes some resources and then puts back updated versions of all.
    # Assign tiers to resources so we can specify how bare the intermediate
    # template needs to be.
    update: async ->
      {cfoTemplate} = s.config.aws
      intermediate = clone cfoTemplate
      intermediate.Resources.SkyCore.Properties.TemplateURL = "https://#{s.config.environmentVariables.skyBucket}.s3.amazonaws.com/templates/core/intermediate.yaml"

      write = async (name, file) ->
        yield s.bucket.putObject name, (yaml file), "text/yaml"

      yield write "template.yaml", cfoTemplate
      yield write "template-intermediate.yaml", intermediate

  # .sky holds the app's tracking metadata, ie hashes of API and handler defs.
  # this is how we determine what's currently deployed.  It's only updated
  # if we successfully complete a publish.
  current =
    fetch: async ->
      try
        yaml yield s.bucket.getObject ".sky"
      catch e
        false

    update: async (endpoint) ->
      data =
        api: md5 yield read s.apiDef
        handlers: md5 yield read(s.pkg, "buffer")
        sky: md5 yield read s.skyDef
        permissions: md5 toJSON s.permissions
        endpoint: endpoint

      yield s.bucket.putObject(".sky", (yaml data), "text/yaml")

    check: async (meta) ->
      # Examine core stack resources to see if we need to wipe away Gateway resources and republish
      updates = []
      updates.push api.tier if !yield api.isCurrent meta
      updates.push skyConfig.tier if !yield skyConfig.isCurrent meta
      updates.push permissions.tier if !permissions.isCurrent meta
      dirtyAPI = !(empty updates)

      # Lambdas are in a special category.  Becuause their ENIs (used when integrated with a VPC) take hours to re-establish, we want to detect when Lambdas are dirty and issue an update out-of-band for CloudFormation, by directly using the AWS API.
      dirtyLambda = !(yield handlers.isCurrent meta)
      {dirtyAPI, dirtyLambda}



  update = async ->
    yield api.update()
    yield skyConfig.update()
    yield handlers.update()
    yield permissions.update()
    yield template.update()
    yield substacks.update()

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
    api
    hostnames
    handlers
    skyConfig
    template
    current
    update
    create
    delete: destroy
  }
