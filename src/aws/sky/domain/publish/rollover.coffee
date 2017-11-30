module.exports = (s) ->
  needsRollover: async ->
    yield "hello"
    # Lookup current in bucket and dig out current domain deployments
    # Is there a current domain?
      # does the hostname differ from our desired hostname?
        # return true
    # else
      # return false

  rollover: async ->
    yield console.error "Graceful rollover is still WIP."
    process.exit()
    # yield confirmRollover()
    # if !s.config.options.hard
    #   # Graceful rollover.
    #   yield s.domain.publish()
    #   yield s.domain.delete old
    # else
    #   # Hard rollover.
    #   yield Promise.all [
    #     s.domain.publish()
    #     s.domain.delete old
    #   ]

# Explain to the developer what they're asking, and confirm they want it.
#confirmRollover = async ->
