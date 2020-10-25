import Path from "path"

# TODO: This won't work in Windows, but there are other Windows compliant things to fix too.
sharedDirectory = ->
  string = Path.resolve "src", "shared"
  if string[string.length - 1] == "/"
    string
  else
    "#{string}/"

export {sharedDirectory}
