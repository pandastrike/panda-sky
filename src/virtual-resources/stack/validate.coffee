import {exists} from "panda-quill"

validate = (config) ->
  {pkg, apiDef, skyDef} = config.aws.stack
  # Confirm it's safe to proceed with the Sky Stack instanciation.
  throw new Error("Unable to find deploy/package.zip") if !(await exists pkg)
  throw new Error("Unable to find api.yaml") if !(await exists apiDef)
  throw new Error("Unable to find sky.yaml") if !(await exists skyDef)

export default validate
