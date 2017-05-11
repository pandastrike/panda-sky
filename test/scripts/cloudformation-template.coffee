assert = require "assert"
{call, async, merge, read, write} = require "fairmont"
{yaml} = require "panda-serialize"

cloudformation = require "../../src/configuration/cloudformation"
configuration = require "../../src/configuration"

appRoot = "test/data/blurb9/"
env = "staging"


call ->
  knowngood = yaml yield read "test/data/blurb9/_cloudformation.yaml"

  config = yield configuration.readApp appRoot
  globals = merge config, {env}
  generated = yield cloudformation.renderTemplate appRoot,  globals
  assert.deepEqual generated, knowngood
