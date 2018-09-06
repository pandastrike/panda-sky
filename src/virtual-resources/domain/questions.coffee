questions = (name, domain) ->
  if name == "publish"
    [
      name: "continue"
      description: """
        This publishes a custom domain at:
            #{domain}
        Would you like to continue? [Y/n]
      """
      default: "n"
    ]
  else if name == "delete"
    [
      name: "continue"
      description: """
        This deletes the custom domain at:
            #{domain}
        This is a destructive operation.
        Would you like to continue? [Y/n]
      """
      default: "n"
    ]
  else
    throw new Error "unknown custom domain action"


export default questions
