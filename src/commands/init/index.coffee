# This sets up an existing directory to hold a Panda Sky project. There are
# different flavors to showcase different mixins.

import MIXINS from "./mixins"


init = (name="core") ->
  try
    if MIXINS[name]
      await do MIXINS[name]
    else
      console.error """
      ERROR: Unknown mixin, #{name}, specified.  Unable to continue.

      Done.
      """
  catch e
    console.error e.stack
  console.log "Done."

export default init
