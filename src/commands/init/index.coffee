{async} = require "fairmont"
{bellChar} = require "../../utils"
MIXINS = require "./mixins"

# This sets up an existing directory to hold a Panda Sky project. There are
# different flavors to showcase different mixins.
module.exports = async (name="core") ->
  try
    if MIXINS[name]
      yield do MIXINS[name]
    else
      console.error """
      ERROR: Unknown mixin, #{name}, specified.  Unable to continue.

      Done.
      """
  catch e
    console.error e.stack
  console.error bellChar
