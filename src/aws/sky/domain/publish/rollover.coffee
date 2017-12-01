{async} = require "fairmont"
module.exports = (s) ->
  needsRollover: async ->
    domains = yield s.meta.domains.fetch()
    if domains
      if domains != s.config.aws.domain[0]
        true
    else
      false

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
