import moment from "moment"
import "moment-duration-format"
import {parse as _parse, relative, join} from "path"
import zlib from "zlib"
import {curry, binary} from "panda-garden"
import {include, isMatch} from "panda-parchment"
import {exists, mkdirp, isDirectory, write as _write, read} from "panda-quill"

shell = (command) ->
  {exec} = require "child_process"
  new Promise (resolve, reject) ->
    exec command, (error, stdout, stderr) ->
      if error
        reject error
      else
        resolve {stdout, stderr}

pathWithUnderscore = (path) -> isMatch /(^|\/)_/, path

# Make a directory at the specified path if it doesn't already exist.
safe_mkdir = (path, mode) ->
  if await exists path
    console.error "Warning: #{path} exists. Skipping."
    return

  mode ||= "0777"
  await mkdirp mode, path

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

stopwatch = ->
  start = Date.now()
  ->
    d = moment.duration Date.now() - start
    if 0 < d.asSeconds() <= 60
      d.format("s[ s]", 1)
    else if 60 < d.asSeconds() < 3600
      d.format("m:ss[ min]", 0)
    else
      d.format("h:mm[ hr]", 0)

parse = (path) ->
  {dir, name, ext} = _parse path
  path: path
  directory: dir
  name: name
  extension: ext

context = curry (_directory, _path) ->
  {path, directory, name, extension} = parse _path
  path: relative _directory, (join directory, name)
  name: name
  source: {path, directory, name, extension}
  target: {}
  data: {}

write = curry binary (directory, {path, target, source}) ->
  if target.content?
    if !target.path?
      extension = if target.extension?
        target.extension
      else if source.extension?
        source.extension
      else ""
      include target,
        parse (join directory, "#{path}#{extension}")
    await mkdirp "0777", (target.directory)
    await _write target.path, target.content

isCompressible = (buffer) -> buffer.length > 1000

gzip = (buffer, level=9) ->
  new Promise (resolve, reject) ->
    zlib.gzip buffer, {level}, (error, result) ->
      if error
        reject error
      else
        resolve result

brotli = (buffer, level=10) ->
  new Promise (resolve, reject) ->
    zlib.brotliCompress buffer, {level}, (error, result) ->
      if error
        reject error
      else
        resolve result

export {pathWithUnderscore, safe_mkdir, safe_cp, bellChar, getVersion, context, write, stopwatch, shell, isCompressible, gzip, brotli}
