{resolve} = require "path"
{async, read} = require "fairmont"
{yaml} = require "panda-serialize"

exports.read = async (appRoot) ->
  try
    config = yaml yield read resolve appRoot, "sky.yaml"
  catch e
    console.error "There was a problem reading this project's configuration.", e.message
    throw e
  config
