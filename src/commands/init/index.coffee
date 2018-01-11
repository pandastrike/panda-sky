{async} = require "fairmont"
{bellChar} = require "../../utils"
DEMOS = require "./demos"

# This sets up an existing directory to hold a Panda Sky project. There are
# different flavors to showcase different mixin demos.
module.exports = async (name="core", {demo}) ->
  try
    if demo && DEMOS[name]
      yield do DEMOS[name]
    else if !demo
      console.error """
      ERROR: The mixin templating feature is not yet implmented.  Please use
        the flag --demo instead.

      Done.
      """
    else
      console.error """
      ERROR: The specified mixin, #{name}, has no demo.  Unable to continue.

      Done.
      """
  catch e
    console.error e.stack
  console.error bellChar
