{resolve} = require "path"
JSCK = require "jsck"
{async, read, merge, keys} = require "fairmont"
{yaml} = require "panda-serialize"

API = require "./api"
SKY = require "./sky"

preprocess = require "./preprocessors"
cloudformation = require "./cloudformation"

compile = async (appRoot, env, profile) ->
  sky = yield readSky appRoot, env  # sky.yaml
  api = yield readAPI appRoot       # api.yaml
  config = merge api, sky, {env, profile}

  if env
    # Run everything through preprocessors to get final config.
    config = yield preprocess config
    config.aws.stacks = yield cloudformation.renderTemplate config

  config

readAPI = async (root) ->
  try
    yield API.read resolve root, "api.yaml"
  catch e
    console.error "Unable to read API description."
    console.error e
    process.exit()


readSky = async (root, env) ->
  try
    yield SKY.read root, env
  catch e
    console.error "Unable to read Sky description."
    console.error e
    process.exit()

module.exports = {compile}
