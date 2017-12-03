{async, empty} = require "fairmont"
interview = require "../../../../interview"

module.exports = (s) ->
  needsRollover: async (name) ->
    {hostnames} = yield s.meta.hostnames.fetch()
    if hostnames && !empty hostnames && name not in hostnames
      true
    else
      false

  rollover: async (newName, options) ->
    oldName = s.meta.hostnames.fetch().hostnames[0]
    yield confirmRollover newName, oldName, options.hard
    if !options.hard
      # Graceful rollover.
      yield s.domain.publish newName
      yield s.domain.delete oldName
    else
      # Hard rollover.
      yield Promise.all [
        s.domain.publish newName
        s.domain.delete oldName
      ]

# Explain to the developer what they're asking, and confirm they want it.
confirmRollover = async (newName, oldName, isHard) ->
  if isHard
    description = hardConfirm newName, oldName
  else
    description = gracefulConfirm newName, oldName


  interview.setup()
  questions = [
    name: "confirm"
    description: description
    default: "n"
  ]

  answers = yield interview.ask questions
  if !answers.confirm
    console.error "Discontinuing custom domain publish."
    console.error "Done."
    process.exit()

gracefulConfirm = (newName, oldName) -> """
  WARNING: You are about to publish a Sky custom domain resource for
  your API endpoint.  However, there is already a custom domain in place.
  You are requesting a graceful rollover from:

    OLD
    - https://#{oldName}

    NEW
    - https://#{newName}

  The full publish and tear-down cycle will take approximately 60 minutes.
  Your old endpoint will not be affected until the new one is confirmed to be
  fully operational.


  Please confirm that you wish to continue. [Y/n]
  """

hardConfirm = (newName, oldName) -> """
  WARNING: You are about to publish a Sky custom domain resource for
  your API endpoint.  However, there is already a custom domain in place.
  You are requesting a hard rollover from:

    OLD
    - https://#{oldName}

    NEW
    - https://#{newName}

  The change will take approximately 30 minutes, during which both endpoints
  will be unavailable.


  Please confirm that you wish to continue. [Y/n]
  """
