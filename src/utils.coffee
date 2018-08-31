import {join} from "path"
import {isMatch, shell, exists, mkdir, isDirectory, read} from "fairmont"
import moment from "moment"
import "moment-duration-format"

pathWithUnderscore = (path) -> isMatch /(^|\/)_/, path

# Make a directory at the specified path if it doesn't already exist.
safe_mkdir = (path, mode) ->
  if await exists path
    console.error "Warning: #{path} exists. Skipping."
    return

  mode ||= "0777"
  await mkdir mode, path

# Copy a file to the target, but only if it doesn't already exist.
safe_cp = (original, target) ->
  if await exists target
    console.error "Warning: #{target} exists. Skipping."
    return

  if await isDirectory original
    await shell "cp -R #{original} #{target}"
  else
    await shell "cp #{original} #{target}"

bellChar = '\u0007'

getVersion = ->
  try
    (JSON.parse await read join __dirname, "..", "..", "..", "package.json").version
  catch e
    console.error "Unable to find package.json to determine version."
    throw e

outputDuration = (start) ->
  d = moment.duration(new Date().getTime() - start)
  if 0 < d.asSeconds() <= 60
    d.format("s[ s]", 1)
  else if 60 < d.asSeconds() < 3600
    d.format("m:ss[ min]", 0)
  else
    d.format("h:mm[ hr]", 0)

export {pathWithUnderscore, safe_mkdir, safe_cp, bellChar, getVersion, outputDuration}
