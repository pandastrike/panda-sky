assert = require "assert"
{describe} = require "amen"

{call, async, merge, read, write} = require "fairmont"
{yaml} = require "panda-serialize"

cloudformation = require "../../src/configuration/cloudformation"
configuration = require "../../src/configuration"

appRoot = "test/data/blurb9/"
env = "staging"

describe "API config transformation", ({describe, test}) ->

  test "matching known good existing config", ->

    knowngoodPath = "test/data/blurb9/_api_config.yaml"
    generatedPath = "test/data/blurb9/_api_config.generated.yaml"

    config = yield configuration.readApp appRoot
    globals = merge config, {env}
    try
      generated = yield cloudformation.apiConfig appRoot,  globals
    catch e
      console.error e.errors
      throw e
    write generatedPath, yaml JSON.parse JSON.stringify generated
    assert.deepEqual (yield read generatedPath), (yield read knowngoodPath)

