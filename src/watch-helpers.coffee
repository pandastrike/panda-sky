{join} = require "path"
{async, shell, exists, stat, isDirectory} = require "fairmont"

{run} = require "panda-9000"

# Tasks
require "./build"
require "./build-update"

module.exports = do async ->
  archive_path = join process.cwd(), "deploy/package.zip"
  node_path = join process.cwd(), "node_modules"
  relativeNodePath = (p) -> p.split(process.cwd())[1]
  relativeBufferPath = (p) -> p.split(join(process.cwd(), "lib"))[1]
  relativeSrcPath = (p) -> p.split(join(process.cwd(), "src"))[1]

  if !(yield exists archive_path)
    console.log "============================================================"
    console.log "Did not detect deploy archive. "
    console.log "One moment while it is constructed. (Wait for Task 'build' to complete)"
    console.log "============================================================\n"
    run "build"

  src = do ->
    # TODO: Fix this to handle .coffee and other extensions better.
    convert = (f) -> f.replace /\.coffee$/, ".js"

    created: (f) ->
      console.log "//   Detected file creation - Adding #{f}\n"
      f = convert f
      run "build-update", ["zip -u #{archive_path} lib#{relativeSrcPath f}"]
    changed: (f) ->
      console.log "//   Detected file change - Updating #{f}\n"
      f = convert f
      run "build-update", ["zip -u #{archive_path} lib#{relativeSrcPath f}"]
    removed: (f) ->
      console.log "//   Detected file deletion - Removing #{f}\n"
      f = convert f
      shell "zip -d #{archive_path} lib#{relativeSrcPath f}"
      .then ->
        shell "rm -r #{join process.cwd(), "lib", relativeSrcPath(f)}"

  node = do ->
    _update = (f) ->
      console.log "//   Detected \"node_modules\" file change - Updating #{f}\n"
      isDirectory f
      .then (isDir) ->
        if isDir
          shell "cp -R #{f} lib#{relativeNodePath f}/ && zip -ur #{archive_path} lib#{relativeNodePath f}/"
        else
          shell "cp #{f} lib#{relativeNodePath f} && zip -u #{archive_path} lib#{relativeNodePath f}"

    created: (f) -> _update f
    changed: (f) -> _update f
    removed: (f) ->
      console.log "//   Detected \"node_modules\" file deletion #{f}\n"
      shell "zip -d #{archive_path} \"lib#{relativeNodePath f}/\*\""
      .then ->
        shell "rm -r #{join process.cwd(), "lib", relativeNodePath(f)}"
        .catch (e) -> # Swallow deletion errors
      .catch (e) -> console.log "File already deleted"

  {src, node}
