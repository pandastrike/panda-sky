{async, isMatch, shell, exists, mkdir, isDirectory} = require "fairmont"

module.exports =

  pathWithUnderscore: (path) -> isMatch /(^|\/)_/, path

  # Make a directory at the specified path if it doesn't already exist.
  safe_mkdir: async (path, mode) ->
    if yield exists path
      console.error "Warning: #{path} exists. Skipping."
      return

    mode ||= "0777"
    yield mkdir mode, path

  # Copy a file to the target, but only if it doesn't already exist.
  safe_cp: async (original, target) ->
    if yield exists target
      console.error "Warning: #{target} exists. Skipping."
      return

    if yield isDirectory original
      yield shell "cp -R #{original} #{target}"
    else
      yield shell "cp #{original} #{target}"

  bellChar: '\u0007'
