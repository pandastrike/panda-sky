# This is some final pre-processing on resources now that we're ready to apply them to a template.  To keep the gateway method description from being too large, they need to be split.  We also need to designate the root resource separately because its association is intrinsic to a Gateway deployment.
import {clone, cat} from "panda-parchment"
import {partition} from "panda-river"

Resources = (config) ->
  # Create "methodSets", a nested array of method descriptions that let us spread them across sub-templates, avoiding running into the size limit.
  methods =
    for _, resource of config.resources
      for _, method of resource.methods
        method

  config.methodSets = (batch for batch from partition 20, cat methods...)
  for set, index in config.methodSets
    config["methodSets#{index}"] = set

  # Remove the root resource, because it needs special handling in template.
  config.rootResource = clone config.resources[config._rootResourceName]
  delete config.resources[config._rootResourceName]
  delete config._rootResourceName

  config

export default Resources
