Build = require "./build"
Equal = require "./equal"

module.exports = (sky) ->
  build: Build sky
  equal: Equal
