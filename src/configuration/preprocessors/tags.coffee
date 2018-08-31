# Accept a configuration for the deployment and come up with tags for every
# resource we label within the stack.  Allow overrides.
Tags = (config) ->
  tally = []
  tags = []
  defaults =
    project: config.name
    skyID: config.projectID
    environment: config.env

  # Apply explicit tags, deleteing defaults if there is an override.
  if config.tags
    for tag in config.tags
      throw new Error "Duplicate tag names are not allowed." if tag.Key in tally
      tags.push(tag)
      tally.push tag.Key
      delete defaults[tag.Key] if defaults[tag.Key]

  # Apply default tags.
  tags.push {Key, Value} for Key, Value of defaults
  config.tags = tags
  config

export default Tags
