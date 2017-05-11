{call, async, merge} = require "fairmont"
{yaml} = require "panda-serialize"

cloudformation = require "../../src/configuration/cloudformation"
configuration = require "../../src/configuration"

appRoot = "test/data/test-app/"
env = "test"

call ->
  config = yield configuration.readApp appRoot
  globals = merge config, {env}
  cfo = yield cloudformation.renderTemplate appRoot,  globals
  console.log yaml cfo
