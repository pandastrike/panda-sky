questions = (name) ->
  [
    name: "override"
    description: """
      WARNING: A stack with the name #{name} already exists, but it
      does not seem to be managed by Sky.  Would you like Sky to override?
      This is a destructive operation. [Y/n]
    """
    default: "n"
  ]

export default questions
